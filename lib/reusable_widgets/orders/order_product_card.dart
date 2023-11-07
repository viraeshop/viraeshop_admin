import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop/items/barrel.dart';
import 'package:viraeshop/orders/barrel.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/extensions/string.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/cylindrical_buttons.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/order_chips.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_api/models/items/items.dart';

import '../../components/styles/colors.dart';

class OrderProductCard extends StatefulWidget {
  const OrderProductCard({
    Key? key,
    required this.orderId,
    required this.product,
    required this.index,
    required this.orderInfo,
    required this.adminId,
    this.admins,
  }) : super(key: key);

  final String orderId;
  final String adminId;
  final Items product;
  final List<AdminModel>? admins;
  final int index;
  final Map<String, dynamic> orderInfo;

  @override
  State<OrderProductCard> createState() => _OrderProductCardState();
}

class _OrderProductCardState extends State<OrderProductCard> {
  int quantity = 0;
  num originalPrice = 0;
  num discountedPrice = 0;
  num discount = 0;
  String dropdownValue = 'confirmed';
  String currentStatus = '';
  bool onLocation = false;
  bool onPhone = false;
  bool onSent = false;
  bool onOrderStage = true;
  List<AdminModel> admins = [];
  bool onEdit = false;
  bool isLoading = false, onDelete = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  List<String> status = [];
  int statusIndex = 0;
  OrderStages? currentStage;
  @override
  void initState() {
    print(quantity);
    currentStage =
        Provider.of<OrderProvider>(context, listen: false).currentStage;
    if (currentStage == OrderStages.receiving) {
      currentStatus = widget.product.receiveStatus;
    } else if (currentStage == OrderStages.processing) {
      currentStatus = widget.product.processingStatus;
    }
    onOrderStage = currentStage == OrderStages.order;
    admins = widget.admins ?? [];
    if ((!onOrderStage && currentStage != OrderStages.admin) &&
        admins.isNotEmpty) {
      dropdownValue = widget.adminId;
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        quantity = widget.product.quantity;
        originalPrice = widget.product.originalPrice;
        discountedPrice = widget.product.productPrice;
        discount = widget.product.discount;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OrderItemsBloc, OrderItemState>(
            listener: (context, state) {
          if (state is RequestFinishedOrderItemState) {
            setState(() {
              if (!(currentStage == OrderStages.admin &&
                      dropdownValue == 'failed') ||
                  !(currentStage == OrderStages.receiving &&
                      status[statusIndex] == 'Failed') ||
                  currentStage == OrderStages.processing) isLoading = false;
              onEdit = false;
            });
            if (onDelete) {
              Provider.of<OrderProvider>(context, listen: false)
                  .deleteProduct(widget.index);
              setState(() {
                onDelete = false;
              });
            }
            if (currentStage == OrderStages.admin &&
                dropdownValue == 'failed') {
              orderUpdate(
                context: context,
                data: const {
                  'processingStatus': 'canceled',
                  'notificationType': 'employee2Admin',
                  'orderStage': 'admin',
                },
                orderId: widget.orderId,
                token: jWTToken,
              );
            }
            if (currentStage == OrderStages.receiving &&
                status[statusIndex] == 'Failed') {
              orderUpdate(
                context: context,
                data: const {
                  'receiveStatus': 'failed',
                  'notificationType': 'employee2Admin',
                  'orderStage': 'receiving',
                },
                orderId: widget.orderId,
                token: jWTToken,
              );
            }
            if (currentStage == OrderStages.processing) {
              orderUpdate(
                context: context,
                data: {
                  /// All the "adminId" field in this class are not referring to
                  /// super Admin, they are referring to employees
                  /// which they can be replaceable at any moment
                  /// work will be done later on employee replacement
                  'adminId': dropdownValue,
                  //'replacedAdminId': widget.product.adminModel.adminId,
                  'notificationType': 'admin2Employee',
                },
                orderId: widget.orderId,
                token: jWTToken,
              );
            }
            if (currentStage == OrderStages.order) {
              num newQuantity =
                  (widget.orderInfo['quantity'] - widget.product.quantity) +
                      quantity;
              num newTotalPrice = (widget.orderInfo['totalPrice'] -
                      widget.product.originalPrice) +
                  originalPrice;
              num newDiscount =
                  (widget.orderInfo['discount'] - widget.product.discount) +
                      discount;
              num newSubTotal =
                  (widget.orderInfo['subTotal'] - widget.product.productPrice) +
                      discountedPrice;

              orderUpdate(
                context: context,
                data: {
                  'totalPrice': newTotalPrice,
                  'subTotal': newSubTotal,
                  'quantity': newQuantity,
                  'price': newSubTotal,
                  'discount': newDiscount,
                },
                orderId: widget.orderId,
                token: jWTToken,
              );
            }
          } else if (state is OnErrorOrderItemState) {
            setState(() {
              isLoading = false;
            });
            snackBar(
              text: state.message,
              context: context,
              color: kRedColor,
              duration: 500,
            );
          }
        }),
        BlocListener<OrdersBloc, OrderState>(
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
                duration: 500,
                color: kRedColor,
              );
            }
          },
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: BlurryModalProgressHUD(
                inAsyncCall: isLoading,
                dismissible: true,
                //color: kNewMainColor,
                progressIndicator: const Center(
                  child: CircularProgressIndicator(
                    color: kNewMainColor,
                  ),
                ),
                child: Container(
                  height: 200.0,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.product.productImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OpaqueButton(
                            onTap: onOrderStage
                                ? () {
                                    if (onEdit) {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      productUpdate(
                                        context: context,
                                        data: {
                                          'id': widget.product.id,
                                          'itemInfo': {
                                            'quantity': quantity,
                                            'productPrice': discountedPrice,
                                            'discount': discount,
                                            'originalPrice': originalPrice,
                                          }
                                        },
                                      );
                                    } else {
                                      setState(() {
                                        onEdit = true;
                                      });
                                    }
                                  }
                                : null,
                            color: onOrderStage ? kRedColor : Colors.grey,
                            icon: !onEdit ? Icons.edit : Icons.done,
                          ),
                          Text(
                            '${widget.product.unitPrice}$bdtSign/unit',
                            style: kSansTextStyleSmallBlack,
                          ),
                        ],
                      ),
                      CylindricalButton(
                        deleteColor: onOrderStage ? kRedColor : Colors.grey,
                        quantity: quantity.toString(),
                        onDelete: onOrderStage
                            ? () {
                                setState(
                                  () {
                                    isLoading = true;
                                    onDelete = true;
                                  },
                                );
                                final orderBloc =
                                    BlocProvider.of<OrderItemsBloc>(context);
                                orderBloc.add(
                                  DeleteOrderItemEvent(
                                    orderId: widget.product.id.toString(),
                                    token: jWTToken,
                                  ),
                                );
                              }
                            : null,
                        onAdd: onEdit
                            ? () {
                                setState(() {
                                  ++quantity;
                                  num originalUnitPrice =
                                      widget.product.originalPrice /
                                          widget.product.quantity;
                                  num discountAmount = widget.product.discount /
                                      widget.product.quantity;
                                  originalPrice += originalUnitPrice;
                                  discountedPrice += widget.product.unitPrice;
                                  discount += discountAmount;
                                });
                              }
                            : null,
                        onReduce: onEdit
                            ? () {
                                setState(() {
                                  --quantity;
                                  num originalUnitPrice =
                                      widget.product.originalPrice /
                                          widget.product.quantity;
                                  num discountAmount = widget.product.discount /
                                      widget.product.quantity;
                                  originalPrice -= originalUnitPrice;
                                  discountedPrice -= widget.product.unitPrice;
                                  discount -= discountAmount;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              widget.product.productSupplier.businessName,
              style: kColoredNameStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product.productName,
                  style: kSansTextStyleSmallBlack,
                ),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$originalPrice$bdtSign',
                      style: const TextStyle(
                        color: kBlackColor,
                        fontFamily: 'SourceSans',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      '$discountedPrice$bdtSign',
                      style: kSansTextStyleBigBlack,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: currentStage == OrderStages.order
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton(
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(10.0),
                  dropdownColor: Colors.white,
                  iconEnabledColor: kSubMainColor,
                  items: generateItems(admins, context),
                  value: dropdownValue,
                  onChanged: (String? value) {
                    bool onOrderOrAdminStage =
                        currentStage == OrderStages.order ||
                            currentStage == OrderStages.admin;
                    setState(() {
                      dropdownValue = value ?? '';
                      if (onOrderOrAdminStage) isLoading = true;
                    });
                    if (onOrderOrAdminStage) {
                      productUpdate(
                        context: context,
                        data: {
                          'id': widget.product.id,
                          'itemInfo': {
                            if (onOrderStage)
                              'availability': value == 'confirmed',
                            if (currentStage == OrderStages.admin)
                              'processingStatus': value,
                          },
                        },
                      );
                    }
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                if (onOrderStage)
                  OutlinedIconWidget(
                    onTap: onOrderStage
                        ? () async {
                            setState(() {
                              onPhone = !onPhone;
                              if (onLocation) onLocation = false;
                            });
                            if (onPhone) {
                              String mobile =
                                  '+880${widget.product.productSupplier.mobile}';
                              final url = Uri.parse('tel:$mobile');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              }
                            }
                          }
                        : null,
                    iconData: Icons.call,
                  ),
                const SizedBox(
                  width: 10.0,
                ),
                if (onPhone && onOrderStage)
                  Expanded(
                    child: Text(
                      '+880${widget.product.productSupplier.mobile}',
                      overflow: TextOverflow.ellipsis,
                      style: kProductNameStylePro,
                      maxLines: 3,
                    ),
                  ),
                const SizedBox(
                  width: 10.0,
                ),
                if (onOrderStage)
                  OutlinedIconWidget(
                    onTap: onOrderStage
                        ? () {
                            setState(() {
                              onLocation = !onLocation;
                              if (onPhone) onPhone = false;
                            });
                          }
                        : null,
                    iconData: Icons.location_pin,
                  ),
                const SizedBox(
                  width: 10.0,
                ),
                if (onLocation && onOrderStage)
                  Expanded(
                    child: Text(
                      widget.product.productSupplier.address,
                      overflow: TextOverflow.ellipsis,
                      style: kProductNameStylePro,
                      maxLines: 3,
                    ),
                  ),
                if (!onOrderStage && currentStage != OrderStages.admin)
                  Consumer<OrderProvider>(builder: (context, provider, any) {
                    int counter =
                        provider.currentStage == OrderStages.receiving ? 2 : 1;
                    if (provider.currentStage == OrderStages.receiving) {
                      status = ['Pending', 'Confirmed', 'Failed'];
                    } else if (provider.currentStage ==
                        OrderStages.processing) {
                      status = ['Send', 'Pending'];
                    } else {
                      status = ['Success'];
                    }
                    return OrderChips(
                      title: provider.currentStage == OrderStages.receiving &&
                              currentStatus.isNotEmpty
                          ? currentStatus.capitalize()
                          : status[statusIndex],
                      onTap: () {
                        if (currentStatus.isEmpty) {
                          if (status[statusIndex] != 'Pending' &&
                              status[statusIndex] != 'Success') {
                            setState(() {
                              isLoading = true;
                            });
                            productUpdate(
                              context: context,
                              data: {
                                'id': widget.product.id,
                                'itemInfo': {
                                  if (provider.currentStage ==
                                      OrderStages.processing)
                                    'adminId': dropdownValue,
                                  if (provider.currentStage ==
                                      OrderStages.receiving)
                                    'receiveStatus':
                                        status[statusIndex].toLowerCase(),
                                },
                              },
                            );
                          }
                          setState(() {
                            if (status.length > counter) {
                              if (status.length - statusIndex == counter) {
                                statusIndex = 0;
                              } else if (statusIndex < status.length) {
                                statusIndex += 1;
                              }
                            }
                          });
                        }
                      },
                      isSelected: status[statusIndex] == 'Pending' &&
                          currentStatus != 'confirmed',
                    );
                  }),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}

class OutlinedIconWidget extends StatelessWidget {
  const OutlinedIconWidget({
    Key? key,
    required this.iconData,
    this.onTap,
    this.height = 30.0,
    this.width = 30.0,
    this.color = const Color(0xff979797),
    this.borderWidth = 1.0,
  }) : super(key: key);

  final IconData iconData;
  final void Function()? onTap;
  final double? height;
  final double? width;
  final Color color;
  final double borderWidth;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(
              color: color,
              width: borderWidth,
            )),
        child: Icon(
          iconData,
          size: 25.0,
          color: color,
        ),
      ),
    );
  }
}

class DropDownMenuWidget extends StatelessWidget {
  const DropDownMenuWidget({
    Key? key,
    required this.color,
    required this.title,
    required this.icon,
  }) : super(key: key);
  final Color color;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OrderChips(
          title: title,
          onTap: null,
          isSelected: false,
        ),
        Container(
          // height: 40.0,
          // width: 40.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(7.0),
          child: Align(
            child: Icon(
              icon,
              color: kBackgroundColor,
              size: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}

List<DropdownMenuItem<String>> generateItems(
    List<AdminModel> admins, BuildContext context) {
  List<DropdownMenuItem<String>> items = [];
  OrderStages currentStage = Provider.of<OrderProvider>(context).currentStage;
  if (currentStage == OrderStages.order || currentStage == OrderStages.admin) {
    List<String> titles = ['Confirmed', 'Failed'];
    items = titles.map((e) {
      return DropdownMenuItem(
        value: e.toLowerCase(),
        child: Text(
          e,
          style: TextStyle(
            color: e == 'Failed' ? kRedColor : kNewMainColor,
            fontSize: 20.0,
            fontFamily: 'SourceSans',
            letterSpacing: 1.3,
          ),
        ),
      );
    }).toList();
  } else {
    items = admins.map((e) {
      return DropdownMenuItem(
        value: e.adminId,
        child: Text(
          e.name,
          style: const TextStyle(
            color: kNewMainColor,
            fontSize: 20.0,
            fontFamily: 'SourceSans',
            letterSpacing: 1.3,
          ),
        ),
      );
    }).toList();
  }
  return items;
}

void productUpdate(
    {required BuildContext context, required Map<String, dynamic> data}) {
  final jWTToken = Hive.box('adminInfo').get('token');
  final ordersItemBloc = BlocProvider.of<OrderItemsBloc>(context);
  ordersItemBloc.add(
    UpdateOrderItemEvent(
      orderModel: data,
      token: jWTToken,
    ),
  );
}

void orderUpdate(
    {required BuildContext context,
    required Map<String, dynamic> data,
    required String orderId,
    token}) {
  final orderBloc = BlocProvider.of<OrdersBloc>(context);
  orderBloc.add(
    UpdateOrderEvent(
      orderId: orderId,
      orderModel: data,
      token: token,
    ),
  );
}
