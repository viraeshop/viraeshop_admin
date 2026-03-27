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
import '../../filters/orderFilters.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    currentStage =
        Provider.of<OrderProvider>(context, listen: false).currentStage;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<OrderProvider>(context, listen: false).updateOrderValues(
        due: widget.orderInfo['due'],
        advance: widget.orderInfo['advance'],
        discount: widget.orderInfo['orderStatus'] == 'confirmed'
            ? widget.orderInfo['discount']
            : 0,
        deliveryFee: widget.orderInfo['deliveryFee'],
        subTotal: widget.orderInfo['orderStatus'] == 'confirmed'
            ? widget.orderInfo['subTotal']
            : 0,
        total: widget.orderInfo['orderStatus'] == 'confirmed'
            ? widget.orderInfo['total']
            : 0,
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
              Map<String, dynamic> filterInfo = {
                'filterType': orderFilter(currentStage!),
                'filterData': {
                  if (currentStage == OrderStages.order)
                    'customerId': widget.userId,
                  if (currentStage == OrderStages.admin)
                    'adminId': widget.userId,
                  if (currentStage == OrderStages.processing) 'isAll': true,
                  if (currentStage == OrderStages.receiving)
                    'status': 'pending',
                  if (currentStage == OrderStages.delivery)
                    'status': 'pending',
                  if (currentStage == OrderStages.delivery && !widget.isManagerView)
                    'deliveryBoyId': widget.userId,
                }
              };
              getOrders(
                data: filterInfo,
                context: context,
              );
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
                  if (state.response.message == 'Task Started') {
                    toast(
                      context: context,
                      title: 'Delivery Started',
                      color: kNewMainColor,
                    );
                    
                    _shouldNavigateToActive = true;

                    context.read<OrdersBloc>().add(
                          GetOrderEvent(
                            orderId: widget.orderInfo['orderId'].toString(),
                            token: jWTToken,
                          ),
                        );

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
                  heightFactor: 0.84,
                  child: Consumer<OrderProvider>(
                      builder: (context, provider, any) {
                    final products = provider.orderProducts;
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        return OrderProductCard(
                          key: ValueKey(products[i].productId),
                          orderId: widget.orderInfo['orderId'].toString(),
                          orderInfo: widget.orderInfo,
                          product: provider.orderProducts[i],
                          onGetAdmins: widget.onGetAdmins,
                          adminId:
                              provider.orderProducts[i].adminModel?.adminId ??
                                  '',
                          admins:
                              provider.currentStage == OrderStages.processing
                                  ? admins
                                  : [
                                      provider.orderProducts[i].adminModel ??
                                          AdminModel.empty()
                                    ],
                          index: i,
                        );
                      },
                    );
                  }),
                ),
                if (!(widget.orderInfo['receiveStatus'] != 'pending' &&
                    currentStage == OrderStages.receiving))
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
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
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final orderBloc =
                                                BlocProvider.of<OrdersBloc>(
                                                    context);
                                            orderBloc.add(
                                              UpdateOrderEvent(
                                                orderId: widget
                                                    .orderInfo['orderId']
                                                    .toString(),
                                                orderModel: {
                                                  'notificationType':
                                                      'employee2Admin',
                                                  'orderStage':
                                                      order.currentStage.name,
                                                  'receiveStatus': 'completed',
                                                  'deliveryStatus': 'pending',
                                                },
                                                token: jWTToken,
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
                                        title: 'Received',
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
                                                   'pending';
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
                                    if (myItems.isNotEmpty && (unstartedItems.isNotEmpty || processingItems.isNotEmpty)) {
                                      bulkActions = Padding(
                                        padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
                                        child: Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            if (unstartedItems.isNotEmpty)
                                              _buildBulkActionButton(
                                                context: context,
                                                label: "Start All",
                                                color: const Color(0xFF38BDF8),
                                                icon: Icons.play_arrow_rounded,
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  final ids = unstartedItems
                                                      .map((e) => e.id)
                                                      .toList();
                                                  _lastUpdatedIds = ids;
                                                  _lastTargetStatus = 'processing';
                                                  _lastStartedAt = DateTime.now();
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
                                                              'startedAt': _lastStartedAt!
                                                                  .toIso8601String(),
                                                            },
                                                          },
                                                        ),
                                                      );
                                                },
                                              ),
                                            if (processingItems.isNotEmpty)
                                              _buildBulkActionButton(
                                                context: context,
                                                label: "Complete All",
                                                color: const Color(0xFF00C896),
                                                icon: Icons.check_circle_outline,
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  final ids = processingItems
                                                      .map((e) => e.id)
                                                      .toList();
                                                  _lastUpdatedIds = ids;
                                                  _lastTargetStatus = 'completed';
                                                  _lastStartedAt = null;
                                                  context
                                                      .read<OrderItemsBloc>()
                                                      .add(
                                                        UpdateOrderItemEvent(
                                                          token: jWTToken,
                                                          orderModel: {
                                                            'id': ids,
                                                            'itemInfo': {
                                                              'processingStatus':
                                                                  'completed',
                                                            },
                                                          },
                                                        ),
                                                      );
                                                },
                                              ),
                                            if (processingItems.isNotEmpty)
                                              _buildBulkActionButton(
                                                context: context,
                                                label: "Report Delay All",
                                                color: const Color(0xFFEF4444),
                                                icon: Icons.history_rounded,
                                                onTap: () => _showBulkDelayDialog(
                                                    context,
                                                    processingItems
                                                        .map((e) => e.id)
                                                        .toList(),
                                                    jWTToken),
                                              ),
                                          ],
                                        ),
                                      );
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
