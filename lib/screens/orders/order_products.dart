import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop/admin/admin_bloc.dart';
import 'package:viraeshop/admin/admin_event.dart';
import 'package:viraeshop/admin/admin_state.dart';
import 'package:viraeshop/orders/barrel.dart';
import 'package:viraeshop/orders/orders_bloc.dart';
import 'package:viraeshop/suppliers/barrel.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/on_error_widget.dart';
import 'package:viraeshop_admin/screens/orders/details.dart';
import 'package:viraeshop_admin/screens/orders/orderRoutineReport.dart';
import 'package:viraeshop_admin/screens/orders/order_screen.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';

import '../../components/styles/colors.dart';
import '../../components/styles/text_styles.dart';
import '../../configs/boxes.dart';
import '../../reusable_widgets/loading_widget.dart';
import '../../reusable_widgets/orders/order_product_card.dart';
import '../../reusable_widgets/send_button.dart';
import 'order_provider.dart';

class OrderProducts extends StatefulWidget {
  const OrderProducts(
      {Key? key,
      required this.customerInfo,
      required this.orderInfo,
      this.onGetAdmins = false})
      : super(key: key);
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> orderInfo;
  final bool onGetAdmins;

  @override
  State<OrderProducts> createState() => _OrderProductsState();
}

class _OrderProductsState extends State<OrderProducts> {
  List<AdminModel> admins = [];
  final jWTToken = Hive.box('adminInfo').get('token');
  bool onError = false;
  bool isLoading = false;
  String errorMessage = '';
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<OrderProvider>(context, listen: false)
        .onUpdateProducts(widget.orderInfo['items'] ?? []);
    if (widget.onGetAdmins) {
      final adminBloc = BlocProvider.of<AdminBloc>(context);
      adminBloc.add(GetAdminsEvent(token: jWTToken));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kBlackColor,
          ),
          title: const Text(
            'Orders',
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
            child: BlocListener<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is FetchedAdminsState) {
                  setState(() {
                    admins = state.adminList ?? [];
                  });
                } else if (state is OnErrorSupplierState) {
                  setState(() {
                    onError = true;
                  });
                }
              },
              child: widget.onGetAdmins && admins.isEmpty
                  ? const LoadingWidget()
                  : onError
                      ? OnErrorWidget(message: errorMessage)
                      : Stack(
                          children: [
                            FractionallySizedBox(
                              heightFactor: 0.84,
                              child: Consumer<OrderProvider>(
                                builder: (context, provider, any) {
                                  return ListView.builder(
                                    itemCount: provider.orderProducts.length,
                                    itemBuilder: (context, i) {
                                      return OrderProductCard(
                                        product: provider.orderProducts[i],
                                        admins: admins,
                                        onNotOrderStage: widget
                                            .onGetAdmins, //This will be used if the order stage is not order
                                        index: i,
                                      );
                                    },
                                  );
                                }
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                  height: 120.0,
                                  padding: const EdgeInsets.all(10.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: kNewMainColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Consumer<OrderProvider>(
                                    builder: (context, provider, any) {
                                      if (provider.currentStage ==
                                          OrderStages.receiving) {
                                        return Center(
                                          child: SendButton(
                                            onTap: () {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              final orderBloc =
                                                  BlocProvider.of<OrdersBloc>(
                                                      context);
                                              orderBloc.add(UpdateOrderEvent(
                                                  orderId: widget
                                                      .orderInfo['orderId'],
                                                  orderModel: const {
                                                    'receiveStatus': 'received',
                                                  },
                                                  token: jWTToken));
                                            },
                                            title: 'Received',
                                            width: 150.0,
                                            color: kBackgroundColor,
                                          ),
                                        );
                                      } else {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Architect',
                                                  style: kSansTextStyleWhite1,
                                                ),
                                                Row(
                                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    ///TODO: Add product discount here..
                                                    Text(
                                                      '${widget.orderInfo['price']}$bdtSign',
                                                      style: const TextStyle(
                                                        color: kBackgroundColor,
                                                        fontFamily:
                                                            'SourceSans',
                                                        fontSize: 15,
                                                        letterSpacing: 1.3,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      '${widget.orderInfo['price']}$bdtSign',
                                                      style:
                                                          kSansTextStyleWhite,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                OutlinedIconWidget(
                                                  onTap: () async {
                                                    String mobile = widget
                                                        .customerInfo['mobile'];
                                                    final url = Uri.parse(
                                                        'tel:$mobile');
                                                    if (await canLaunchUrl(
                                                        url)) {
                                                      await launchUrl(url);
                                                    }
                                                  },
                                                  iconData: Icons.call,
                                                  height: 40.0,
                                                  width: 40.0,
                                                  color: kBackgroundColor,
                                                  borderWidth: 3.0,
                                                ),
                                                InkWell(
                                                  onTap: provider
                                                              .currentStage ==
                                                          OrderStages.processing
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
                          ],
                        ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
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
