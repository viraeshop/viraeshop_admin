import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/orders/details.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_admin/features/order_management/screens/active_delivery_screen.dart';
import 'package:viraeshop_admin/features/order_management/screens/payment_collection_screen.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:viraeshop_api/models/items/items.dart';
import 'package:viraeshop_bloc/items/barrel.dart';

import '../../components/styles/colors.dart';
import '../../components/styles/text_styles.dart';
import '../../configs/boxes.dart';
import '../../reusable_widgets/orders/functions.dart';
import '../../reusable_widgets/orders/order_product_card.dart';
import '../../reusable_widgets/send_button.dart';
import 'order_provider.dart';

class OrderProducts extends StatefulWidget {
  const OrderProducts(
      {Key? key,
      required this.customerInfo,
      required this.orderInfo,
      required this.userId,
      this.processorSeen = false,
      this.onGetAdmins = false,
      this.isManagerView = false})
      : super(key: key);
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> orderInfo;
  final bool onGetAdmins;
  final String userId;
  final bool processorSeen;
  final bool isManagerView;
  
  @override
  State<OrderProducts> createState() => _OrderProductsState();
}

class _OrderProductsState extends State<OrderProducts> {
  List<AdminModel> admins = [];
  final jWTToken = Hive.box('adminInfo').get('token');
  bool onError = false;
  bool isLoading = false;
  String errorMessage = '';
  OrderStages? currentStage;
  List<dynamic> _lastUpdatedIds = [];
  String? _lastTargetStatus;
  DateTime? _lastStartedAt;
  bool _shouldNavigateToActive = false;
  String? selectedParcelType;

  @override
  void initState() {
    // TODO: implement initState
    currentStage =
        Provider.of<OrderProvider>(context, listen: false).currentStage;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<OrderProvider>(context, listen: false).updateOrderValues(
        due: widget.orderInfo['due'],
        advance: widget.orderInfo['advance'],
        discount: widget.orderInfo['discount'],
        deliveryFee: widget.orderInfo['deliveryFee'],
        subTotal: widget.orderInfo['subTotal'],
        total: widget.orderInfo['total'],
      );
      final List rawItems = widget.orderInfo['items'] ?? [];
      final List<Items> items = rawItems.map((e) => Items.fromJson(e)).toList();
      Provider.of<OrderProvider>(context, listen: false)
          .onUpdateProducts(items);
    });
    // if (widget.onGetAdmins) {
    //   final adminBloc = BlocProvider.of<AdminBloc>(context);
    //   adminBloc.add(GetAdminsEvent(token: jWTToken));
    //   isLoading = true;
    // }/
    if (!widget.orderInfo['seen'] && currentStage == OrderStages.order) {
      isLoading = true;
      Map<String, dynamic> info = {
        'seen': true,
      };
      updateOrderRead(
          info, context, widget.orderInfo['orderId'].toString(), jWTToken);
    } else if (currentStage == OrderStages.processing &&
        !widget.orderInfo['processed']) {
      isLoading = true;
      Map<String, dynamic> info = {
        'decrementProcessingCount': true,
        'processed': true,
      };
      updateOrderRead(
          info, context, widget.orderInfo['orderId'].toString(), jWTToken);
    } else if (currentStage == OrderStages.receiving &&
        !widget.orderInfo['received']) {
      isLoading = true;
      Map<String, dynamic> info = {
        'decrementReceiveCount': true,
        'received': true,
      };
      updateOrderRead(
          info, context, widget.orderInfo['orderId'].toString(), jWTToken);
    } else if (currentStage == OrderStages.admin) {
      if (!widget.processorSeen) {
        isLoading = true;
        Map<String, dynamic> info = {
          'adminProcessingCount': true,
          'adminId': widget.userId,
        };
        updateOrderRead(
            info, context, widget.orderInfo['orderId'].toString(), jWTToken);
      }
    }
    super.initState();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    // Provider.of<OrderProvider>(context, listen: false).resetValues();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save a reference to the OrderProvider
  }

  @override
  void dispose() {
    // Safely reset values using the saved reference
    //_orderProvider?.resetValues();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kBlackColor,
          ),
          title: Text(
            currentStage == OrderStages.order
                ? 'Orders'
                : currentStage == OrderStages.admin
                    ? 'Admin Order'
                    : currentStage == OrderStages.emergency
                        ? 'Emergency Issues'
                        : currentStage == OrderStages.awaitingCustomer
                            ? 'Awaiting Decision'
                            : currentStage == OrderStages.processing
                                ? 'Processing Order'
                                : currentStage == OrderStages.receiving
                                    ? 'Receiving Order'
                                    : 'Delivery Order',
            style: kTotalSalesStyle,
          ),
          centerTitle: true,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<OrderItemsBloc, OrderItemState>(
              listener: (context, state) {
                if (state is RequestFinishedOrderItemState) {
                  if (_lastUpdatedIds.isNotEmpty && _lastTargetStatus != null) {
                    context.read<OrderProvider>().batchUpdateItemsByIds(
                          _lastUpdatedIds,
                          processingStatus: _lastTargetStatus,
                          startedAt: _lastStartedAt,
                        );
                    _lastUpdatedIds = [];
                    _lastTargetStatus = null;
                    _lastStartedAt = null;
                  }
                  setState(() {
                    isLoading = false;
                  });
                } else if (state is OnErrorOrderItemState) {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
            ),
            BlocListener<OrdersBloc, OrderState>(
              listenWhen: (prev, current) {
                return current is OnErrorOrderState ||
                    current is RequestFinishedOrderState ||
                    current is FetchedOrderState;
              },
              listener: (context, state) {
                if (state is RequestFinishedOrderState) {
                  // Re-fetch order to sync data across all components
                  context.read<OrdersBloc>().add(
                        GetOrderEvent(
                          orderId: widget.orderInfo['orderId'].toString(),
                          token: jWTToken,
                        ),
                      );

                  if (state.response.message == 'Task Started') {
                    toast(
                      context: context,
                      title: 'Delivery Started',
                      color: kNewMainColor,
                    );
                    
                    _shouldNavigateToActive = true;

                    context.read<OrderProvider>().updateOrderInfo('onDelivery', true);
                    context.read<OrderProvider>().updateOrderInfo('deliveryStatus', 'In Transit');
                  } else if ((currentStage == OrderStages.receiving ||
                          currentStage == OrderStages.admin) &&
                      isLoading) {
                    toast(
                      context: context,
                      title: 'Successfully updated',
                      color: kNewMainColor,
                    );
                  }
                } else if (state is FetchedOrderState) {
                  // Update Provider with newly fetched data to sync UI
                  context.read<OrderProvider>().updateOrderValues(
                        due: state.orderModel.due,
                        advance: state.orderModel.advance,
                        discount: state.orderModel.discount,
                        deliveryFee: state.orderModel.deliveryFee,
                        subTotal: state.orderModel.subTotal,
                        total: state.orderModel.total,
                      );
                  context.read<OrderProvider>().updateOrderInfo('deliveryFee', state.orderModel.deliveryFee);

                  if (_shouldNavigateToActive == true) {
                    _shouldNavigateToActive = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveDeliveryScreen(
                          order: state.orderModel,
                          task: state.orderModel.deliveryTask,
                        ),
                      ),
                    );
                  }
                } else if (state is OnErrorOrderState) {
                  snackBar(
                    text: state.message,
                    context: context,
                    color: kRedColor,
                    duration: 400,
                  );
                }

                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: screenSize.height,
            width: screenSize.width,
            color: Colors.white10.withOpacity(0.1),
            child: Stack(
              children: [
                FractionallySizedBox(
                  heightFactor: (currentStage == OrderStages.emergency ||
                                 currentStage == OrderStages.awaitingCustomer)
                      ? 1.0
                      : 0.84,
                  child: Consumer<OrderProvider>(
                      builder: (context, provider, any) {
                    List<Items> products = provider.orderProducts;
                    
                    // SPLIT-ORDER LOGIC: Filter items assigned to the current staff member
                    if (currentStage == OrderStages.admin && !widget.isManagerView) {
                      products = products.where((item) => 
                        item.effectiveAdminId == widget.userId || 
                        item.adminModel?.adminId == widget.userId
                      ).toList();
                    }
                    
                    // EMERGENCY & AWAITING DECISION LOGIC: Show only affected items
                    if (currentStage == OrderStages.emergency) {
                      products = products.where((item) => 
                        item.processingStatus.toLowerCase() == 'delayed' || 
                        item.processingStatus.toLowerCase() == 'failed'
                      ).toList();
                    } else if (currentStage == OrderStages.awaitingCustomer) {
                      products = products.where((item) => 
                        item.customerDecisionDeadline != null
                      ).toList();
                    }

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        return OrderProductCard(
                          key: ValueKey(products[i].productId),
                          orderId: widget.orderInfo['orderId'].toString(),
                          orderInfo: widget.orderInfo,
                          product: products[i],
                          onGetAdmins: widget.onGetAdmins,
                          adminId:
                              products[i].adminModel?.adminId ??
                                  '',
                          admins:
                              provider.currentStage == OrderStages.processing
                                  ? admins
                                  : [
                                      products[i].adminModel ??
                                          AdminModel.empty()
                                    ],
                          index: i,
                        );
                      },
                    );
                  }),
                ),
                if (!(widget.orderInfo['receiveStatus'] != 'pending' &&
                    currentStage == OrderStages.receiving) &&
                    currentStage != OrderStages.emergency &&
                    currentStage != OrderStages.awaitingCustomer)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          height: currentStage == OrderStages.admin
                              ? null // Auto-height for Wrap
                              : currentStage == OrderStages.receiving
                                  ? 80.0
                                  : 130.0,
                          padding: const EdgeInsets.all(10.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: kNewMainColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Consumer<OrderProvider>(
                            builder: (context, order, any) {
                              if (currentStage == OrderStages.receiving ||
                                  currentStage == OrderStages.admin ||
                                  currentStage == OrderStages.delivery) {
                                bool receiveItemsConfirmed =
                                    order.orderProducts.every((item) {
                                  print(item.receiveStatus);
                                  return (item.receiveStatus == 'confirmed' ||
                                          item.receiveStatus == 'failed') &&
                                      currentStage == OrderStages.receiving;
                                });
                                Widget? sendButtonWidget;
                                if (currentStage == OrderStages.receiving) {
                                  sendButtonWidget = Center(
                                    child: SendButton(
                                      onTap: () {
                                        if (receiveItemsConfirmed) {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Confirm Hub Arrival'),
                                              content: const Text('Are you sure all items have reached the hub? This will transition the order to the next stage.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    context.read<OrdersBloc>().add(
                                                      MarkAtHubEvent(
                                                        orderId: widget.orderInfo['orderId'].toString(),
                                                        token: jWTToken,
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('Confirm', style: TextStyle(color: kNewMainColor)),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          showToast(
                                            'Please make sure you have confirmed all items',
                                            backgroundColor: kRedColor,
                                            context: context,
                                          );
                                        }
                                      },
                                      title: 'MARK AT HUB',
                                      textStyle: kTotalSalesStyle,
                                      width: 250.0,
                                      color: kBackgroundColor,
                                    ),
                                  );
                                }
                      
                                if (currentStage == OrderStages.delivery) {
                                  final String? deliveryBoyId =
                                      widget.orderInfo['deliveryBoyId']
                                          ?.toString();
                                  final String currentUserId = widget.userId;
                      
                                  if (widget.isManagerView) {
                                    sendButtonWidget = Center(
                                      child: SendButton(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrdersDetails(
                                                customerInfo:
                                                    widget.customerInfo,
                                                orderInfo: widget.orderInfo,
                                              ),
                                            ),
                                          );
                                        },
                                        title: 'MANAGE DELIVERY',
                                        textStyle: kTotalSalesStyle,
                                        width: 250.0,
                                        color: kBackgroundColor,
                                      ),
                                    );
                                  } else if (deliveryBoyId == null) {
                                    sendButtonWidget = Center(
                                      child: SendButton(
                                        onTap: () {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          orderUpdate(
                                            context: context,
                                            data: {
                                              'deliveryBoyId': currentUserId,
                                              'notificationType':
                                                  'admin2Employee',
                                              'deliveryStatus': 'pending',
                                              'durationMinutes': 60,
                                            },
                                            orderId: widget
                                                .orderInfo['orderId']
                                                .toString(),
                                            token: jWTToken,
                                          );
                                        },
                                        title: 'ACCEPT DELIVERY',
                                        textStyle: kTotalSalesStyle,
                                        width: 250.0,
                                        color: kBackgroundColor,
                                      ),
                                    );
                                  } else if (deliveryBoyId == currentUserId) {
                                    final ordersObj =
                                        Orders.fromJson(widget.orderInfo);
                                    OrderTask? deliveryTask;
                                    if (widget.orderInfo['OrderProcessors'] !=
                                        null) {
                                      final tasks = (widget.orderInfo[
                                              'OrderProcessors'] as List)
                                          .map((e) => OrderTask.fromJson(e))
                                          .toList();
                                      try {
                                        deliveryTask = tasks.firstWhere(
                                          (t) =>
                                              t.taskType == 'delivery' &&
                                              t.adminId.toString() ==
                                                  currentUserId,
                                        );
                                      } catch (e) {
                                        deliveryTask = null;
                                      }
                                    }
                      
                                    // Fallback: If task is null but order is assigned to me and not started, treat as pending
                                     final bool isTaskPending =
                                         ordersObj.deliveryStatus.toLowerCase() ==
                                                 'pending' || 
                                         ordersObj.deliveryStatus.toLowerCase() ==
                                                 'assigned';
                                                print('Delivery task status: ${ordersObj.deliveryStatus}');
                                    if (isTaskPending) {
                                      sendButtonWidget = Center(
                                        child: SendButton(
                                          onTap: () {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              BlocProvider.of<OrdersBloc>(
                                                      context)
                                                  .add(
                                                UpdateOrderEvent(
                                                  orderId: widget
                                                      .orderInfo['orderId']
                                                      .toString(),
                                                  orderModel: {
                                                    'startDelivery': true,
                                                    'notificationType':
                                                        'admin2Customer',
                                                  },
                                                  token: jWTToken,
                                                ),
                                              );
                                          },
                                          title: 'START DELIVERY',
                                          textStyle: kTotalSalesStyle,
                                          width: 250.0,
                                          color: kBackgroundColor,
                                        ),
                                      );
                                    } else {
                                      sendButtonWidget = Center(
                                        child: SendButton(
                                          onTap: () {
                                            // If delivery boy already reached customer, go straight to payment
                                            if (ordersObj.deliveryStatus.toLowerCase() == 'reached') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentCollectionScreen(
                                                    order: ordersObj,
                                                    task: deliveryTask,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ActiveDeliveryScreen(
                                                    order: ordersObj,
                                                    task: deliveryTask,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          title: 'TRACK DELIVERY',
                                          textStyle: kTotalSalesStyle,
                                          width: 250.0,
                                          color: kBackgroundColor,
                                        ),
                                      );
                                    }
                                  }
                                }
                      
                                if (currentStage == OrderStages.admin) {
                                  final myItems = order.orderProducts
                                      .where((item) =>
                                          item.effectiveAdminId ==
                                          widget.userId)
                                      .toList();
                      
                                  final unstartedItems = myItems
                                      .where((item) =>
                                          item.startedAt == null &&
                                          item.processingStatus == 'assigned')
                                      .toList();
                                  final processingItems = myItems
                                      .where((item) =>
                                          item.startedAt != null &&
                                          item.processingStatus == 'processing')
                                      .toList();
                      
                                  Widget bulkActions = const SizedBox.shrink();
                                  if (myItems.isNotEmpty) {
                                    final hasPendingUnavail = myItems.any(
                                        (item) =>
                                            item.processingStatus == 'failed');
                                    final hasReadyItems = myItems.any(
                                        (item) =>
                                            item.processingStatus ==
                                            'completed');

                                    if (unstartedItems.isNotEmpty ||
                                        processingItems.isNotEmpty) {
                                      bulkActions = Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15.0, bottom: 8.0),
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            if (unstartedItems.isNotEmpty)
                                              _buildBulkActionButton(
                                                context: context,
                                                label: "Start All",
                                                color:
                                                    const Color(0xFF38BDF8),
                                                icon:
                                                    Icons.play_arrow_rounded,
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  final ids = unstartedItems
                                                      .map((e) => e.id)
                                                      .toList();
                                                  _lastUpdatedIds = ids;
                                                  _lastTargetStatus =
                                                      'processing';
                                                  _lastStartedAt =
                                                      DateTime.now();
                                                  context
                                                      .read<OrderItemsBloc>()
                                                      .add(
                                                        UpdateOrderItemEvent(
                                                          token: jWTToken,
                                                          orderModel: {
                                                            'id': ids,
                                                            'itemInfo': {
                                                              'processingStatus':
                                                                  'processing',
                                                              'startedAt':
                                                                  _lastStartedAt!
                                                                      .toIso8601String(),
                                                            },
                                                          },
                                                        ),
                                                      );
                                                },
                                              ),
                                          ],
                                        ),
                                      );
                                    } else if (currentStage ==
                                        OrderStages.admin) {
                                      if (hasPendingUnavail) {
                                        bulkActions = Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: kRedColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                color: kRedColor
                                                    .withOpacity(0.3)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded,
                                                  color: kRedColor),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  "Waiting for Customer Decision on Unavailable Items",
                                                  style: TextStyle(
                                                      color: kRedColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (hasReadyItems) {
                                        bulkActions = Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            children: [
                                              const Text("SELECT PARCEL TYPE",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color: kSubMainColor,
                                                      letterSpacing: 1.2)),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  _buildParcelTypeChip(
                                                      "Big Truck",
                                                      Icons.local_shipping),
                                                  const SizedBox(width: 8),
                                                  _buildParcelTypeChip(
                                                      "Van",
                                                      Icons.delivery_dining),
                                                  const SizedBox(width: 8),
                                                  _buildParcelTypeChip(
                                                      "Motorcycle",
                                                      Icons.motorcycle),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              SendButton(
                                                onTap: selectedParcelType ==
                                                        null
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        final readyIds = myItems
                                                            .where((item) =>
                                                                item.processingStatus ==
                                                                'completed')
                                                            .map((e) => e.id)
                                                            .toList();
                                                        _showHubTransitDialog(
                                                            context, readyIds);
                                                      },
                                                title: "SEND TO HUB",
                                                color: kNewMainColor,
                                                width: double.infinity,
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  }
                      
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (sendButtonWidget != null)
                                        sendButtonWidget,
                                      bulkActions,
                                    ],
                                  );
                                } else {
                                  return sendButtonWidget ?? const SizedBox.shrink();
                                }
                              } else {
                                bool orderItemsConfirmed = order.orderProducts
                                    .any((element) =>
                                        element.availability == true);
                                // SchedulerBinding.instance.addPostFrameCallback((f){
                                //   order.recalculateTotals();
                                // });
                                return Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.customerInfo['name'],
                                          style: kSansTextStyleWhite,
                                        ),
                                        const Text(
                                          'Sub-Total',
                                          style: kSansTextStyleWhite1,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          widget.customerInfo['role'],
                                          style: kSansTextStyleWhite1,
                                        ),
                                        Row(
                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ///TODO: Add product discount here..
                                            Text(
                                              '${orderItemsConfirmed ? order.total : 0.00}$bdtSign',
                                              style: const TextStyle(
                                                color: kBackgroundColor,
                                                fontFamily: 'SourceSans',
                                                fontSize: 15,
                                                letterSpacing: 1.3,
                                                decoration: TextDecoration
                                                    .lineThrough,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10.0,
                                            ),
                                            Text(
                                              '${orderItemsConfirmed ? order.subTotal : 0.00}$bdtSign',
                                              style: kSansTextStyleWhite,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlinedIconWidget(
                                          onTap: () async {
                                            String mobile =
                                                widget.customerInfo['mobile'];
                                            final url =
                                                Uri.parse('tel:$mobile');
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            }
                                          },
                                          iconData: Icons.call,
                                          height: 40.0,
                                          width: 40.0,
                                          color: kBackgroundColor,
                                          borderWidth: 3.0,
                                        ),
                                        if (currentStage !=
                                            OrderStages.processing)
                                          InkWell(
                                            onTap: order.currentStage ==
                                                        OrderStages
                                                            .processing ||
                                                    (order.currentStage ==
                                                            OrderStages
                                                                .order &&
                                                        !orderItemsConfirmed)
                                                ? null
                                                : () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            OrdersDetails(
                                                          customerInfo: widget
                                                              .customerInfo,
                                                          orderInfo: widget
                                                              .orderInfo,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            child: const BigButton(),
                                          )
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          )),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulkActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
        onPressed: onTap,
      ),
    );
  }

  void _showBulkDelayDialog(
      BuildContext context, List<dynamic> ids, String token) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Bulk Report Delay",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              content: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Reason for delay on all items...",
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel",
                        style: TextStyle(color: Color(0xFF94A3B8)))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        context.read<OrderItemsBloc>().add(
                              UpdateOrderItemEvent(
                                token: token,
                                orderModel: {
                                  'id': ids,
                                  'itemInfo': {
                                    'processingStatus': 'delayed',
                                    'note': controller.text,
                                  },
                                },
                              ),
                            );
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text("Submit",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ));
  }

  void _showHubTransitDialog(BuildContext context, List<dynamic> ids) {
    Duration tempDuration = const Duration(hours: 1); // Default
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Final Batch Complete",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order will be sent via $selectedParcelType. Please set the estimated time to reach the Receive/Delivery Hub.",
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: ThemeData.dark(),
                child: SizedBox(
                  height: 150,
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: TextFormField(
                          initialValue: "60",
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              suffixText: "min",
                              suffixStyle: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                          onChanged: (val) {
                            tempDuration =
                                Duration(minutes: int.tryParse(val) ?? 60);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                isLoading = true;
              });
              _lastUpdatedIds = ids;
              _lastTargetStatus = 'completed';
              _lastStartedAt = null;
              context.read<OrderItemsBloc>().add(
                    UpdateOrderItemEvent(
                      token: jWTToken,
                      orderModel: {
                        'id': ids,
                        'itemInfo': {
                          'processingStatus': 'completed',
                          'hubDurationMinutes': tempDuration.inMinutes,
                          'parcelType': selectedParcelType,
                        },
                      },
                    ),
                  );
            },
            child: const Text("Confirm & Submit",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelTypeChip(String type, IconData icon) {
    bool isSelected = selectedParcelType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedParcelType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kNewMainColor : kSubMainColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? kNewMainColor : kSubMainColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: isSelected ? Colors.white : kSubMainColor),
            const SizedBox(width: 4),
            Text(type,
                style: TextStyle(
                  color: isSelected ? Colors.white : kSubMainColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                )),
          ],
        ),
      ),
    );
  }
}

class BigButton extends StatelessWidget {
  const BigButton({
    Key? key,
    this.width = 150,
  }) : super(key: key);
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: kBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Details',
            style: kSansTextStyleBigBlack,
          ),
          Icon(
            FontAwesomeIcons.chevronRight,
            size: 20.0,
            color: kBlackColor,
          ),
        ],
      ),
    );
  }
}

void updateOrderRead(Map<String, dynamic> info, BuildContext context,
    String orderId, String token) {
  final orderBloc = BlocProvider.of<OrdersBloc>(context);
  orderBloc.add(
    UpdateOrderEvent(
      orderId: orderId,
      orderModel: info,
      token: token,
    ),
  );
}
