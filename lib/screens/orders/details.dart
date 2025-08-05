import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_api/models/items/items.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/order_chips.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_bloc/transactions/transactions_bloc.dart';
import 'package:viraeshop_bloc/transactions/transactions_state.dart';

import '../../components/styles/colors.dart';
import '../../components/styles/text_styles.dart';

class OrdersDetails extends StatefulWidget {
  const OrdersDetails({
    Key? key,
    required this.customerInfo,
    required this.orderInfo,
  }) : super(key: key);
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> orderInfo;
  @override
  State<OrdersDetails> createState() => _OrdersDetailsState();
}

class _OrdersDetailsState extends State<OrdersDetails> {
  bool onEditCustomerInfo = false;
  String selected = '';
  final TextEditingController addressController = TextEditingController();
  final TextEditingController deliveryFeeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  List<String> buttonTitles = ['Confirmed', 'Pending', 'Canceled'];
  final jWTToken = Hive.box('adminInfo').get('token');
  final adminId = Hive.box('adminInfo').get('adminId');
  bool isLoading = false;
  List<Items> orderItems = [];
  @override
  void initState() {
    // TODO: implement initState
    orderItems =
        Provider.of<OrderProvider>(context, listen: false).orderProducts;
    OrderStages currentStage =
        Provider.of<OrderProvider>(context, listen: false).currentStage;
    if (currentStage == OrderStages.delivery) {
      buttonTitles = ['Deliver', 'Delay', 'Failed'];
    }
    addressController.text = widget.orderInfo['shippingAddress'];
    discountController.text = widget.orderInfo['discount'].toString();
    deliveryFeeController.text = widget.orderInfo['deliveryFee'].toString();
    advanceController.text = widget.orderInfo['advance'].toString();
    super.initState();
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kBlackColor,
          ),
          title: const Text(
            'Details',
            style: kTotalSalesStyle,
          ),
          centerTitle: true,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<OrdersBloc, OrderState>(
              listener: (context, state) {
                if (state is RequestFinishedOrderState) {
                  setState(() {
                    isLoading = false;
                  });
                  toast(context: context, title: state.response.message);
                } else if (state is OnErrorOrderState) {
                  setState(() {
                    isLoading = false;
                  });
                  snackBar(
                    text: state.message,
                    context: context,
                    duration: 400,
                    color: kRedColor,
                  );
                }
              },
            ),
            BlocListener<TransactionsBloc, TransactionState>(
              listener: (context, state) {
                if (state is RequestFinishedTransactionState) {
                  setState(() {
                    isLoading = false;
                  });
                  toast(context: context, title: state.response.message);
                } else if (state is OnErrorTransactionState) {
                  setState(() {
                    isLoading = false;
                  });
                  snackBar(
                    text: state.message,
                    context: context,
                    duration: 400,
                    color: kRedColor,
                  );
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              height: screenSize.height,
              width: screenSize.width,
              color: const Color(0xffF9F9F9),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    heightFactor: 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Shipping',
                          style: kSansTextStyleBigBlack,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0)),
                          child: Container(
                            height: 200.0,
                            width: double.infinity,
                            padding: const EdgeInsets.all(13.0),
                            decoration: BoxDecoration(
                              color: kBackgroundColor,
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.customerInfo['name'],
                                      style: kColoredNameStyle,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          onEditCustomerInfo =
                                              !onEditCustomerInfo;
                                        });
                                        if (onEditCustomerInfo &&
                                            widget.orderInfo[
                                                    'shippingAddress'] !=
                                                addressController.text) {
                                          Provider.of<OrderProvider>(context)
                                              .updateOrderInfo(
                                            'shippingAddress',
                                            addressController.text,
                                          );
                                        }
                                      },
                                      child: Text(
                                        onEditCustomerInfo ? 'Done' : 'Change',
                                        style: const TextStyle(
                                          color: Color(0xffDB3022),
                                          fontFamily: 'TenorSans',
                                          fontSize: 15,
                                          letterSpacing: 1.3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                if (onEditCustomerInfo)
                                  TextField(
                                    controller: addressController,
                                    maxLines: 3,
                                    style: kBlackTenorStyle,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(10.0),
                                    ),
                                  )
                                else
                                  Text(
                                    '🚋 ${addressController.text}',
                                    maxLines: 3,
                                    style: kBlackTenorStyle,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Text(
                          'Delivery Options',
                          style: kSansTextStyleBigBlack,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            DeliveryOptions(),
                            DeliveryOptions(),
                            DeliveryOptions(),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Consumer<OrderProvider>(
                            builder: (context, provider, any) {
                          return Column(
                            children: [
                              TextRow(
                                title: 'Delivery-Fee',
                                controller: deliveryFeeController,
                              ),
                              TextRow(
                                title: 'Total',
                                isEditable: false,
                                subTitle: provider.total.toString(),
                              ),
                              TextRow(
                                title: 'Discount',
                                controller: discountController,
                              ),
                              TextRow(
                                title: 'Sub-total',
                                isEditable: false,
                                subTitle: provider.subTotal.toString(),
                              ),
                              TextRow(
                                title: 'Advance',
                                controller: advanceController,
                              ),
                              TextRow(
                                title: 'Due',
                                isEditable: false,
                                subTitle: provider.due.toString(),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                            ],
                          );
                        })
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.orderInfo['orderStatus'] != 'success')
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                          buttonTitles.length,
                                          (index) => Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: OrderChips(
                                                  title: buttonTitles[index],
                                                  onTap: () {
                                                    final orderProvider =
                                                        Provider.of<
                                                                OrderProvider>(
                                                            context,
                                                            listen: false);
                                                    final orderBloc =
                                                        BlocProvider.of<
                                                                OrdersBloc>(
                                                            context);
                                                    OrderStages currentStage =
                                                        orderProvider
                                                            .currentStage;
                                                    setState(() {
                                                      selected =
                                                          buttonTitles[index];
                                                      isLoading = true;
                                                    });
                                                    if (currentStage ==
                                                        OrderStages.order) {
                                                      Map<String, dynamic>
                                                          orderInfo = {
                                                        'orderStage': 'order',
                                                        'notificationType':
                                                            'admin2Customer',
                                                        'orderStatus':
                                                            buttonTitles[index]
                                                                .toLowerCase(),
                                                        'adminId': adminId,
                                                        if (buttonTitles[index]
                                                                .toLowerCase() ==
                                                            'confirmed')
                                                          'processingStatus':
                                                              'pending',
                                                        if (buttonTitles[index]
                                                                .toLowerCase() ==
                                                            'confirmed')
                                                          'incrementProcessingCount':
                                                              true,
                                                      };
                                                      orderBloc.add(
                                                        UpdateOrderEvent(
                                                          orderId: widget
                                                              .orderInfo[
                                                                  'orderId']
                                                              .toString(),
                                                          orderModel: orderInfo,
                                                          token: jWTToken,
                                                        ),
                                                      );
                                                    } else if (currentStage ==
                                                        OrderStages.delivery) {
                                                      orderBloc.add(
                                                        UpdateOrderEvent(
                                                          orderId: widget
                                                              .orderInfo[
                                                                  'orderId']
                                                              .toString(),
                                                          orderModel: {
                                                            'orderStage':
                                                                'delivery',
                                                            'notificationType':
                                                                'admin2Customer',
                                                            if (buttonTitles[
                                                                    index] ==
                                                                'Failed')
                                                              'deliveryStatus':
                                                                  buttonTitles[
                                                                          index]
                                                                      .toLowerCase(),
                                                            if (buttonTitles[
                                                                    index] ==
                                                                'Failed')
                                                              'orderStatus':
                                                                  'failed',
                                                            if (buttonTitles[
                                                                    index] ==
                                                                'Deliver')
                                                              'onDelivery':
                                                                  true,
                                                            if (buttonTitles[
                                                                    index] ==
                                                                'Delay')
                                                              'delayDelivery':
                                                                  true,
                                                          },
                                                          token: jWTToken,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  isSelected:
                                                      buttonTitles[index] ==
                                                          selected,
                                                  width: 100,
                                                  height: 50,
                                                ),
                                              )),
                                    ),
                                    // const SizedBox(
                                    //   width: 10,
                                    // ),
                                    Consumer<OrderProvider>(
                                        builder: (context, provider, any) {
                                      if (provider.currentStage ==
                                              OrderStages.order ||
                                          provider.currentStage ==
                                              OrderStages.delivery) {
                                        return OrderChips(
                                          width: 100,
                                          height: 50,
                                          title: 'Update',
                                          onTap: () {
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
                                                orderModel: provider.orderInfo,
                                                token: jWTToken,
                                              ),
                                            );
                                          },
                                          isSelected: false,
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    }),
                                  ],
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Order Delivered Successfully..',
                              style: kProductNameStylePro,
                            ),
                        ],
                      ),
                    ),
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

class TextRow extends StatefulWidget {
  const TextRow({
    Key? key,
    required this.title,
    this.isEditable = true,
    this.subTitle = '',
    this.controller,
  }) : super(key: key);
  final String title;
  final bool isEditable;
  final String? subTitle;
  final TextEditingController? controller;

  @override
  State<TextRow> createState() => _TextRowState();
}

class _TextRowState extends State<TextRow> {
  bool onEdit = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.title}:',
          style: kBlackTenorStyle,
        ),
        Row(
          children: [
            if (onEdit)
              SizedBox(
                width: 100,
                child: TextField(
                  controller: widget.controller,
                  style: kBlackTenorStyle,
                  cursorColor: kNewMainColor,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                ),
              )
            else
              Text(
                '${widget.isEditable ? widget.controller!.text : widget.subTitle}$bdtSign',
                style: kBlackTenorStyle,
              ),
            const SizedBox(
              width: 10.0,
            ),
            Consumer<OrderProvider>(builder: (context, provider, any) {
              return IconButton(
                onPressed: widget.isEditable
                    ? () {
                        if (onEdit) {
                          switch (widget.title) {
                            case 'Delivery-Fee':
                              num deliveryFee = provider.deliveryFee,
                                  total = provider.total,
                                  subTotal = provider.subTotal;
                              deliveryFee = num.parse(
                                  widget.controller!.text.isNotEmpty
                                      ? widget.controller!.text
                                      : '0');
                              total -= provider.deliveryFee;
                              subTotal -= provider.deliveryFee;
                              total += deliveryFee;
                              subTotal += deliveryFee;
                              provider.updateValue(
                                  updatingValue: Values.deliveryFee,
                                  values: {
                                    'deliveryFee': deliveryFee,
                                    'total': total,
                                    'subTotal': subTotal,
                                  });
                              provider.updateOrderInfo(
                                  'deliveryFee', deliveryFee);
                              provider.updateOrderInfo('total', total);
                              provider.updateOrderInfo('subTotal', subTotal);
                              break;
                            case 'Discount':
                              num discount = provider.discount,
                                  total = provider.total,
                                  subTotal = provider.subTotal;
                              discount = num.parse(
                                  widget.controller!.text.isNotEmpty
                                      ? widget.controller!.text
                                      : '0');
                              total -= provider.discount;
                              subTotal += provider.discount;
                              total += discount;
                              subTotal -= discount;
                              provider.updateValue(
                                  updatingValue: Values.discount,
                                  values: {
                                    'discount': discount,
                                    'total': total,
                                    'subTotal': subTotal,
                                  });
                              provider.updateOrderInfo('discount', discount);
                              provider.updateOrderInfo('total', total);
                              provider.updateOrderInfo('subTotal', subTotal);
                              break;
                            case 'Advance':
                              num advance = provider.advance,
                                  due = provider.due,
                                  subTotal = provider.subTotal;
                              advance = num.parse(
                                  widget.controller!.text.isNotEmpty
                                      ? widget.controller!.text
                                      : '0');
                              due = subTotal - advance;
                              provider.updateValue(
                                  updatingValue: Values.advance,
                                  values: {
                                    'advance': advance,
                                    'due': due,
                                  });
                              provider.updateOrderInfo('advance', advance);
                              provider.updateOrderInfo('due', due);
                              break;
                          }
                        }
                        setState(() {
                          onEdit = !onEdit;
                        });
                      }
                    : null,
                icon: Icon(
                  onEdit ? Icons.done : Icons.edit,
                ),
              );
            }),
          ],
        )
      ],
    );
  }
}

class DeliveryOptions extends StatelessWidget {
  const DeliveryOptions({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
      child: Container(
        height: 150.0,
        width: 120.0,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(18.0),
          image: const DecorationImage(
            image: AssetImage('assets/orders/Free-delivery.png'),
          ),
        ),
      ),
    );
  }
}

//SendButton(
//                             color: kNewMainColor,
//                             onTap: () {
//                               List<Map<String, dynamic>> items = [];
//                               for (var element in orderItems) {
//                                 final product = {
//                                   'productId': element.productId,
//                                   'buyPrice': element.buyPrice,
//                                   'isInventory': false,
//                                   'productName': element.productName,
//                                   'productPrice': element.productPrice,
//                                   'unitPrice': element.unitPrice,
//                                   'quantity': element.quantity,
//                                   'productCode': element.productCode,
//                                   'originalPrice': element.originalPrice,
//                                   'productImage': element.productImage,
//                                   'discount': element.discount,
//                                   'discountPercent': element.discountPercent,
//                                 };
//                                 items.add(product);
//                               }
//                               final transactionInfo = {
//                                 'price': widget.orderInfo['subTotal'],
//                                 'quantity': widget.orderInfo['quantity'],
//                                 'adminId': adminId,
//                                 'items': items,
//                                 'isWithNonInventory': false,
//                                 'customerId': widget.orderInfo['customerId'],
//                                 'role': widget.customerInfo['role'],
//                                 'paid': widget.orderInfo['subTotal'],
//                                 'due': 0,
//                                 'advance': 0,
//                                 'discount': widget.orderInfo['discount'],
//                                 'profit': widget.orderInfo['profit'],
//                               };
//                               setState(() {
//                                 isLoading = true;
//                               });
//                               final transactionBloc =
//                                   BlocProvider.of<TransactionsBloc>(context);
//                               transactionBloc.add(
//                                 AddTransactionEvent(
//                                   token: jWTToken,
//                                   transactionModel: transactionInfo,
//                                 ),
//                               );
//                             },
//                             title: 'Approve',
//                           )
