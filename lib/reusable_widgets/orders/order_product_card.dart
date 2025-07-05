import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_bloc/items/barrel.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
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
    this.onGetAdmins = false,
  }) : super(key: key);

  final String orderId;
  final String adminId;
  final Items product;
  final bool onGetAdmins;
  final List<AdminModel>? admins;
  final int index;
  final Map<String, dynamic> orderInfo;

  @override
  State<OrderProductCard> createState() => _OrderProductCardState();
}

class _OrderProductCardState extends State<OrderProductCard> {
  num newQuantity = 0;
  num newTotalPrice = 0;
  num newDiscount = 0;
  num newSubTotal = 0;
  num newDueBalance = 0;
  String? dropdownValue;
  String currentStatus = '';
  bool onLocation = false;
  bool onPhone = false;
  bool onSent = false;
  bool onOrderStage = true;
  bool onEdit = false;
  bool isLoading = false, onDelete = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  List<String> status = [];
  int statusIndex = 0;
  OrderStages? currentStage;
  bool disable = false;
  bool isAdminsLoading = false;
  bool onAdminsError = false;

  @override
  void initState() {
    currentStage =
        Provider.of<OrderProvider>(context, listen: false).currentStage;
    if (widget.product.availability != null) {
      disable = !widget.product.availability!;
    }
    if (currentStage == OrderStages.receiving) {
      currentStatus = widget.product.receiveStatus;
    } else if (currentStage == OrderStages.processing) {
      currentStatus = widget.product.processingStatus;
    }
    onOrderStage = currentStage == OrderStages.order;
    if (onOrderStage && widget.product.availability != null) {
      dropdownValue = widget.product.availability! ? 'confirmed' : 'failed';
    }
    if ((!onOrderStage && currentStage != OrderStages.admin) &&
        widget.product.supplyAdmins.isNotEmpty) {
      dropdownValue = widget.adminId;
    }
    if (currentStage == OrderStages.admin &&
        (widget.product.processingStatus != 'pending' &&
            widget.product.processingStatus.isNotEmpty)) {
      dropdownValue = widget.product.processingStatus;
    }
    super.initState();
  }

  // @override
  // void deactivate() {
  //   // TODO: implement deactivate
  //   super.deactivate();
  // }
  //
  @override
  void dispose() {
    // TODO: implement dispose
    // Reset all state variables
    newQuantity = 0;
    newTotalPrice = 0;
    newDiscount = 0;
    newSubTotal = 0;
    newDueBalance = 0;
    dropdownValue = null;
    currentStatus = '';
    onLocation = false;
    onPhone = false;
    onSent = false;
    onOrderStage = true;
    onEdit = false;
    isLoading = false;
    onDelete = false;
    status = [];
    statusIndex = 0;
    currentStage = null;
    disable = false;
    isAdminsLoading = false;
    onAdminsError = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OrderItemsBloc, OrderItemState>(
            listenWhen: (prev, current) {
          if ((current is RequestFinishedOrderItemState && isLoading) ||
              (current is OnErrorOrderItemState && isLoading)) {
            return true;
          } else {
            return false;
          }
        }, listener: (context, state) {
          if (state is RequestFinishedOrderItemState) {
            if (!(currentStage == OrderStages.admin &&
                    dropdownValue == 'failed') ||
                !(currentStage == OrderStages.receiving &&
                    status[statusIndex] == 'Failed') ||
                currentStage == OrderStages.processing) {
              if (kDebugMode) {
                print('Turn off loading');
              }
              setState(() {
                isLoading = false;
              });
            }
            if (currentStage == OrderStages.admin) {
              Provider.of<OrderProvider>(context, listen: false)
                  .updateProcessingStatus(dropdownValue ?? '', widget.index);
              if (dropdownValue == 'failed') {
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
              if (dropdownValue == 'confirmed' || dropdownValue == 'failed') {
                print(dropdownValue);
                Provider.of<OrderProvider>(context, listen: false)
                    .updateItemAvailability(
                  dropdownValue == 'confirmed' ? true : false,
                  widget.index,
                );
              }
              if (onDelete || dropdownValue == 'failed') {
                setState(() {
                  newQuantity =
                      widget.orderInfo['quantity'] - widget.product.quantity;
                  newTotalPrice =
                      widget.orderInfo['total'] - widget.product.originalPrice;
                  newDiscount =
                      widget.orderInfo['discount'] - widget.product.discount;
                  newSubTotal = widget.orderInfo['subTotal'] -
                      widget.product.productPrice;
                  if (widget.orderInfo['due'] != 0) {
                    newDueBalance =
                        widget.orderInfo['due'] - widget.product.productPrice;
                  }
                });
                orderUpdate(
                  context: context,
                  data: {
                    'total': newTotalPrice,
                    'subTotal': newSubTotal,
                    'quantity': newQuantity,
                    'price': newSubTotal,
                    'discount': newDiscount,
                    if (widget.orderInfo['due'] != 0)
                      'due':
                          widget.orderInfo['due'] - widget.product.productPrice,
                  },
                  orderId: widget.orderId,
                  token: jWTToken,
                );
              } else {
                print(dropdownValue);
                setState(() {
                  newQuantity =
                      (widget.orderInfo['quantity'] - widget.product.quantity) +
                          widget.product.editableQuantity;
                  newTotalPrice = (widget.orderInfo['total'] -
                          widget.product.originalPrice) +
                      widget.product.editableOriginalPrice;
                  newDiscount =
                      (widget.orderInfo['discount'] - widget.product.discount) +
                          widget.product.editableDiscount;
                  newSubTotal = (widget.orderInfo['subTotal'] -
                          widget.product.productPrice) +
                      widget.product.editableProductPrice;
                  if (widget.orderInfo['due'] != 0) {
                    newDueBalance = (widget.orderInfo['due'] -
                            widget.product.productPrice) +
                        widget.product.editableProductPrice;
                  }
                });
                orderUpdate(
                  context: context,
                  data: {
                    'total': newTotalPrice,
                    'subTotal': newSubTotal,
                    'quantity': newQuantity,
                    'price': newSubTotal,
                    'discount': newDiscount,
                    if (widget.orderInfo['due'] != 0)
                      'due': (widget.orderInfo['due'] -
                              widget.product.productPrice) +
                          widget.product.editableProductPrice,
                  },
                  orderId: widget.orderId,
                  token: jWTToken,
                );
              }
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
          listenWhen: (prev, curr) {
            return isLoading;
          },
          listener: (context, state) {
            if (state is RequestFinishedOrderState) {
              if (currentStage == OrderStages.order) {
                if (onDelete) {
                  Provider.of<OrderProvider>(context, listen: false)
                      .deleteProduct(widget.index);
                }
              }
              setState(() {
                isLoading = false;
                if (onEdit) onEdit = false;
                if (onDelete) onDelete = false;
                if (dropdownValue == 'failed') disable = true;
                if (dropdownValue == 'confirmed') disable = false;
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
      child: SizedBox(
        height: 370,
        width: double.infinity,
        child: Stack(
          //fit: StackFit.,
          children: [
            Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: disable ||
                        (widget.product.processingStatus == 'pending' &&
                            currentStage == OrderStages.receiving)
                    ? 0.5
                    : 1,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    OpaqueButton(
                                      onTap: onOrderStage && !disable
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
                                                      'quantity': widget.product
                                                          .editableQuantity,
                                                      'productPrice': widget
                                                          .product
                                                          .editableProductPrice,
                                                      'discount': widget.product
                                                          .editableDiscount,
                                                      'originalPrice': widget
                                                          .product
                                                          .editableOriginalPrice,
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
                                      color: onOrderStage && !disable
                                          ? kRedColor
                                          : Colors.grey,
                                      icon: !onEdit ? Icons.edit : Icons.done,
                                    ),
                                    Text(
                                      '${widget.product.unitPrice}$bdtSign/unit',
                                      style: kSansTextStyleSmallBlack,
                                    ),
                                  ],
                                ),
                                CylindricalButton(
                                  deleteColor: onOrderStage && !disable
                                      ? kRedColor
                                      : Colors.grey,
                                  quantity: widget.product.editableQuantity
                                      .toString(),
                                  onDelete: onOrderStage && !disable
                                      ? () {
                                          setState(
                                            () {
                                              isLoading = true;
                                              onDelete = true;
                                            },
                                          );
                                          final orderBloc =
                                              BlocProvider.of<OrderItemsBloc>(
                                                  context);
                                          orderBloc.add(
                                            DeleteOrderItemEvent(
                                              orderId:
                                                  widget.product.id.toString(),
                                              token: jWTToken,
                                            ),
                                          );
                                        }
                                      : null,
                                  onAdd: onEdit
                                      ? () {
                                          num originalUnitPrice =
                                              widget.product.originalPrice /
                                                  widget.product.quantity;
                                          num discountAmount =
                                              widget.product.discount /
                                                  widget.product.quantity;
                                          Provider.of<OrderProvider>(context,
                                                  listen: false)
                                              .updateEditableProductsFields(
                                                  widget.index,
                                                  EditingOperation.all, {
                                            'quantity': widget
                                                    .product.editableQuantity +
                                                1,
                                            'originalPrice': widget.product
                                                    .editableOriginalPrice +
                                                originalUnitPrice,
                                            'discountedPrice': widget.product
                                                    .editableProductPrice +
                                                widget.product.unitPrice,
                                            'discount': widget
                                                    .product.editableDiscount +
                                                discountAmount,
                                          });
                                        }
                                      : null,
                                  onReduce: onEdit
                                      ? () {
                                          num originalUnitPrice =
                                              widget.product.originalPrice /
                                                  widget.product.quantity;
                                          num discountAmount =
                                              widget.product.discount /
                                                  widget.product.quantity;
                                          Provider.of<OrderProvider>(context,
                                                  listen: false)
                                              .updateEditableProductsFields(
                                                  widget.index,
                                                  EditingOperation.all, {
                                            'quantity': widget
                                                    .product.editableQuantity -
                                                1,
                                            'originalPrice': widget.product
                                                    .editableOriginalPrice -
                                                originalUnitPrice,
                                            'discountedPrice': widget.product
                                                    .editableProductPrice -
                                                widget.product.unitPrice,
                                            'discount': widget
                                                    .product.editableDiscount -
                                                discountAmount,
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
                                '${widget.product.editableOriginalPrice}$bdtSign',
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
                                '${widget.product.editableProductPrice}$bdtSign',
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
                          if (currentStage != OrderStages.delivery &&
                              currentStage != OrderStages.receiving)
                            Expanded(
                              child: SizedBox(
                                width: 100,
                                child: DropdownButtonFormField(
                                  //underline: const SizedBox(),
                                  decoration: const InputDecoration(
                                    hintText: 'Select',
                                    border: InputBorder.none,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  dropdownColor: Colors.white,
                                  iconEnabledColor: kSubMainColor,
                                  items: generateItems(
                                      widget.product.productSupplier.admins,
                                      context),
                                  value: dropdownValue,
                                  onChanged: currentStage ==
                                              OrderStages.order ||
                                          (currentStage ==
                                                  OrderStages.processing &&
                                              !disable) ||
                                          (currentStage == OrderStages.admin &&
                                              !disable)
                                      ? (dynamic value) {
                                          bool onOrderOrAdminStage =
                                              currentStage ==
                                                      OrderStages.order ||
                                                  currentStage ==
                                                      OrderStages.admin;
                                          setState(() {
                                            dropdownValue =
                                                (value ?? '') as String?;
                                            if (onOrderOrAdminStage) {
                                              isLoading = true;
                                            }
                                          });
                                          if (onOrderOrAdminStage) {
                                            productUpdate(
                                              context: context,
                                              data: {
                                                'id': widget.product.id,
                                                'itemInfo': {
                                                  if (onOrderStage)
                                                    'availability':
                                                        value == 'confirmed',
                                                  if (currentStage ==
                                                      OrderStages.admin)
                                                    'processingStatus': value,
                                                },
                                              },
                                            );
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          if (onOrderStage)
                            OutlinedIconWidget(
                              onTap: onOrderStage && !disable
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
                              onTap: onOrderStage && !disable
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
                          if ((currentStage == OrderStages.receiving && widget.orderInfo['receiveStatus'] == 'pending') ||
                              currentStage == OrderStages.processing || currentStage == OrderStages.delivery)
                            Consumer<OrderProvider>(
                                builder: (context, provider, any) {
                              int counter =
                                  provider.currentStage == OrderStages.receiving
                                      ? 2
                                      : 1;
                              if (provider.currentStage ==
                                  OrderStages.receiving) {
                                status = ['Receiving', 'Confirmed', 'Failed'];
                              } else if (provider.currentStage ==
                                  OrderStages.processing) {
                                status = ['Send', 'Pending'];
                              } else {
                                status = ['Success'];
                              }
                              return OrderChips(
                                title: provider.currentStage ==
                                                OrderStages.receiving &&
                                            currentStatus.isNotEmpty ||
                                        provider.currentStage ==  
                                                OrderStages.processing &&
                                            currentStatus.isNotEmpty
                                    ? currentStatus.capitalize()
                                    : status[statusIndex],
                                onTap: onStatusChange() && !disable
                                    ? () {
                                        setState(() {
                                          if (currentStage ==
                                              OrderStages.receiving) {
                                            if (status.length > counter) {
                                              if (statusIndex == counter) {
                                                statusIndex = 0;
                                              } else if (statusIndex <
                                                  status.length) {
                                                statusIndex += 1;
                                              }
                                            }
                                          }
                                        });
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
                                                    OrderStages.processing)
                                                  'processingStatus': 'pending',
                                                if (provider.currentStage ==
                                                    OrderStages.receiving)
                                                  'receiveStatus':
                                                      status[statusIndex]
                                                          .toLowerCase() == 'receiving' ? 'pending' : status[statusIndex]
                                                          .toLowerCase(),
                                              },
                                            },
                                          );
                                        }
                                        setState(() {
                                          if (currentStage ==
                                              OrderStages.processing) {
                                            if (status.length > counter) {
                                              if (statusIndex == counter) {
                                                statusIndex = 0;
                                              } else if (statusIndex <
                                                  status.length) {
                                                statusIndex += 1;
                                              }
                                            }
                                          }
                                        });
                                      }
                                    : null,
                                isSelected: onSelect(),
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
              ),
            ),
            if (!disable &&
                (widget.product.processingStatus == 'pending' &&
                    currentStage == OrderStages.receiving))
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      FontAwesomeIcons.spinner,
                      size: 40,
                      color: kSubMainColor,
                    ),
                    Text(
                      'Under processing',
                      style: kBigErrorTextStyle.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // This will change the button's color to green
  bool onSelect() {
    if (currentStage == OrderStages.processing) {
      return status[statusIndex] == 'Pending' || currentStatus == 'pending';
    } else {
      return status[statusIndex] == 'Pending' && currentStatus != 'confirmed';
    }
  }

  // This will check if the status is not empty
  bool onStatusChange() {
    if (currentStage == OrderStages.receiving) {
      return currentStatus.isEmpty || currentStatus == 'failed';
    } else {
      return currentStatus.isEmpty;
    }
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

List<DropdownMenuItem> generateItems(List admins, BuildContext context) {
  List<DropdownMenuItem> items = [];
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
        value: e['adminId'],
        child: Text(
          e['name'],
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
