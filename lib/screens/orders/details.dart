import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop/orders/barrel.dart';
import 'package:viraeshop/orders/orders_bloc.dart';
import 'package:viraeshop/orders/orders_event.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/order_chips.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';

import '../../components/styles/colors.dart';
import '../../components/styles/text_styles.dart';

class OrdersDetails extends StatefulWidget {
  const OrdersDetails(
      {Key? key, required this.customerInfo, required this.orderInfo})
      : super(key: key);
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
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    OrderStages currentStage =
        Provider.of<OrderProvider>(context, listen: false).currentStage;
    if (currentStage == OrderStages.delivery) {
      buttonTitles = ['Completed', 'Pending', 'Failed'];
    }
    addressController.text = widget.customerInfo['address'];
    discountController.text = widget.orderInfo['discount'].toString();
    deliveryFeeController.text = widget.orderInfo['deliveryFee'].toString();
    advanceController.text = widget.orderInfo['advance'].toString();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<OrderProvider>(context, listen: false).updateOrderValues(
        due: widget.orderInfo['due'],
        advance: widget.orderInfo['advance'],
        discount: widget.orderInfo['discount'],
        deliveryFee: widget.orderInfo['deliveryFee'],
        subTotal: widget.orderInfo['price'] - widget.orderInfo['discount'],
        total: widget.orderInfo['price'],
      );
    });
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
        body: BlocListener<OrdersBloc, OrderState>(
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
                                            widget.customerInfo['address'] !=
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
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
                                title: 'Sub-total',
                                isEditable: false,
                                subTitle: provider.subTotal.toString(),
                              ),
                              TextRow(
                                title: 'Discount',
                                controller: discountController,
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<OrderProvider>(
                                builder: (context, provider, any) {
                              if (provider.currentStage == OrderStages.order) {
                                return OrderChips(
                                  width: 120,
                                  height: 50,
                                  title: 'Update',
                                  onTap: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final orderBloc =
                                        BlocProvider.of<OrdersBloc>(context);
                                    orderBloc.add(
                                      UpdateOrderEvent(
                                        orderId: widget.orderInfo['orderId']
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
                            const SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                              buttonTitles.length,
                              (index) => OrderChips(
                                    title: buttonTitles[index],
                                    onTap: () {
                                      final orderProvider =
                                          Provider.of<OrderProvider>(context,
                                              listen: false);
                                      final orderBloc =
                                          BlocProvider.of<OrdersBloc>(context);
                                      OrderStages currentStage =
                                          orderProvider.currentStage;
                                      setState(() {
                                        selected = buttonTitles[index];
                                        isLoading = true;
                                      });
                                      if (currentStage == OrderStages.order) {
                                        Map<String, dynamic> orderInfo = {
                                          'orderStatus':
                                              buttonTitles[index].toLowerCase(),
                                          if (buttonTitles[index]
                                                  .toLowerCase() ==
                                              'confirmed')
                                            'processingStatus': 'pending',
                                        };
                                        orderBloc.add(
                                          UpdateOrderEvent(
                                            orderId: widget.orderInfo['orderId']
                                                .toString(),
                                            orderModel: orderInfo,
                                            token: jWTToken,
                                          ),
                                        );
                                      } else if (currentStage ==
                                          OrderStages.delivery) {
                                        orderBloc.add(
                                          UpdateOrderEvent(
                                            orderId: widget.orderInfo['orderId']
                                                .toString(),
                                            orderModel: {
                                              'deliveryStatus':
                                                  buttonTitles[index]
                                                      .toLowerCase(),
                                              if(buttonTitles[index] == 'Completed')'orderStatus': 'success',
                                              if(buttonTitles[index] == 'Failed')'orderStatus': 'failed',
                                            },
                                            token: jWTToken,
                                          ),
                                        );
                                      }
                                    },
                                    isSelected: buttonTitles[index] == selected,
                                    width: 120,
                                    height: 50,
                                  )),
                        ),
                      ],
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
                              provider.updateOrderInfo('subTotal', due);
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
