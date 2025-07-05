import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/orders/details.dart';
import 'package:viraeshop_api/models/admin/admins.dart';

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
      this.onGetAdmins = false})
      : super(key: key);
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> orderInfo;
  final bool onGetAdmins;
  final String userId;
  final bool processorSeen;

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

  @override
  void initState() {
    // TODO: implement initState
    currentStage =
        Provider.of<OrderProvider>(context, listen: false).currentStage;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<OrderProvider>(context, listen: false)
          .onUpdateProducts(widget.orderInfo['items'] ?? []);
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
                  if (currentStage == OrderStages.delivery) 'status': 'pending',
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
        body: BlocListener<OrdersBloc, OrderState>(
          listenWhen: (prev, current) {
            if (current is OnErrorOrderState ||
                current is RequestFinishedOrderState) {
              return true;
            } else {
              return false;
            }
          },
          listener: (context, state) {
            if (state is RequestFinishedOrderState) {
              setState(() {
                isLoading = false;
              });
            } else if (state is OnErrorOrderState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
                duration: 400,
              );
            }
          },
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
                          orderId: widget.orderInfo['orderId'].toString(),
                          orderInfo: widget.orderInfo,
                          product: provider.orderProducts[i],
                          onGetAdmins: widget.onGetAdmins,
                          adminId: provider.orderProducts[i].adminModel.adminId,
                          admins:
                              provider.currentStage == OrderStages.processing
                                  ? admins
                                  : [provider.orderProducts[i].adminModel],
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
                          height: currentStage == OrderStages.receiving ||
                                  currentStage == OrderStages.admin
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
                              if (order.currentStage == OrderStages.receiving ||
                                  currentStage == OrderStages.admin) {
                                bool adminItemsConfirmed = order.orderProducts
                                    .every((element) =>
                                        element.processingStatus ==
                                            'confirmed' ||
                                        element.processingStatus == 'failed');
                                bool receiveItemsConfirmed = order.orderProducts
                                    .every((item) =>
                                        item.receiveStatus == 'confirmed' ||
                                        item.receiveStatus == 'failed');
                                return Center(
                                  child: SendButton(
                                    onTap: () {
                                      if (receiveItemsConfirmed ||
                                          adminItemsConfirmed) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        final orderBloc =
                                            BlocProvider.of<OrdersBloc>(
                                                context);
                                        orderBloc.add(
                                          UpdateOrderEvent(
                                            orderId: widget.orderInfo['orderId']
                                                .toString(),
                                            orderModel: {
                                              'notificationType':
                                                  'employee2Admin',
                                              'orderStage':
                                                  order.currentStage.name,
                                              if (order.currentStage ==
                                                  OrderStages.receiving)
                                                'receiveStatus': 'completed',
                                              if (order.currentStage ==
                                                  OrderStages.receiving)
                                                'deliveryStatus': 'pending',
                                              if (order.currentStage ==
                                                  OrderStages.admin)
                                                'processingStatus': 'confirmed',
                                              if (order.currentStage ==
                                                  OrderStages.admin)
                                                'incrementReceiveCount': true,
                                              if (order.currentStage ==
                                                  OrderStages.admin)
                                                'receiveStatus': 'pending',
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
                                    title:
                                        order.currentStage == OrderStages.admin
                                            ? 'Send To Delivery Hub'
                                            : 'Received',
                                    textStyle: kTotalSalesStyle,
                                    width: 250.0,
                                    color: kBackgroundColor,
                                  ),
                                );
                              } else {
                                bool orderItemsConfirmed = order.orderProducts
                                    .any((element) =>
                                        element.availability ?? false);
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
                                                decoration:
                                                    TextDecoration.lineThrough,
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
                                                            OrderStages.order &&
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
                                                          orderInfo:
                                                              widget.orderInfo,
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
