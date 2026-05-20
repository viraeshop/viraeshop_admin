import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:viraeshop_admin/reusable_widgets/orders/functions.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_api/models/items/items.dart';
import 'package:viraeshop_admin/features/order_management/screens/processing_timer_screen.dart';

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
  bool onEdit = false;
  bool onOrderStage = false;
  bool isLoading = false, onDelete = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  List<String> status = [];
  int statusIndex = 0;
  OrderStages? currentStage;
  Duration selectedDuration = Duration.zero;
  bool disable = false;
  bool isAdminsLoading = false;
  bool onAdminsError = false;
  Timer? _progressTimer;

  String? _lastAdminId;
  int _lastEstimatedTime = 0;
  String _lastProcessingStatus = '';
  DateTime? _lastStartedAt;

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
        (widget.product.productSupplier?.admins.isNotEmpty ?? false)) {
      if (widget.product.effectiveAdminId == null ||
          widget.product.effectiveAdminId!.isEmpty) {
        dropdownValue = null;
      } else {
        final validAdmins = widget.product.productSupplier!.admins;
        bool isValid = validAdmins
            .any((a) => a['adminId'] == widget.product.effectiveAdminId);
        dropdownValue = isValid ? widget.product.effectiveAdminId : null;
      }
    }
    if (currentStage == OrderStages.admin &&
        (widget.product.processingStatus != 'pending' &&
            widget.product.processingStatus.isNotEmpty)) {
      dropdownValue = widget.product.processingStatus;
    }
    if (widget.product.estimatedTime > 0) {
      selectedDuration = Duration(minutes: widget.product.estimatedTime);
    }
    _startProgressTimer();
    super.initState();
  }

  List<int> _getRelatedProductIds() {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    return provider.orderProducts
        .where((p) => p.supplierId == widget.product.supplierId)
        .map((p) => p.id)
        .toList();
  }

  // @override
  // void deactivate() {
  //   // TODO: implement deactivate
  //   super.deactivate();
  // }
  //
  @override
  void dispose() {
    _progressTimer?.cancel();
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
    // Subscribe to OrderProvider so sibling cards rebuild on batch updates
    context.watch<OrderProvider>();

    if (widget.product.effectiveAdminId != _lastAdminId) {
      _lastAdminId = widget.product.effectiveAdminId;
      if ((!onOrderStage && currentStage != OrderStages.admin) &&
          (widget.product.productSupplier?.admins.isNotEmpty ?? false)) {
        if (_lastAdminId == null || _lastAdminId!.isEmpty) {
          dropdownValue = null;
        } else {
          final validAdmins = widget.product.productSupplier!.admins;
          bool isValid = validAdmins.any((a) => a['adminId'] == _lastAdminId);
          dropdownValue = isValid ? _lastAdminId : null;
        }
      }
    }
    if (widget.product.estimatedTime != _lastEstimatedTime) {
      _lastEstimatedTime = widget.product.estimatedTime;
      if (_lastEstimatedTime > 0) {
        selectedDuration = Duration(minutes: _lastEstimatedTime);
      }
    }
    if (widget.product.processingStatus != _lastProcessingStatus) {
      _lastProcessingStatus = widget.product.processingStatus;
      if (currentStage == OrderStages.admin &&
          (_lastProcessingStatus != 'pending' &&
              _lastProcessingStatus.isNotEmpty)) {
        dropdownValue = _lastProcessingStatus;
      }
      if (currentStage == OrderStages.processing) {
        currentStatus = _lastProcessingStatus;
      }
    }
    if (widget.product.startedAt != _lastStartedAt) {
      _lastStartedAt = widget.product.startedAt;
      _startProgressTimer();
    }

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
            if (currentStage == OrderStages.receiving) {
              Provider.of<OrderProvider>(context, listen: false)
                  .updateReceiveStatus(
                      status[statusIndex].toLowerCase(), widget.index);
              if (status[statusIndex] == 'Failed') {
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
            }
            if (currentStage == OrderStages.processing) {
              if (dropdownValue != null) {
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
              } else {
                if (kDebugMode) {
                  print(
                      'Skipping orderUpdate: No employee selected for processing.');
                }
              }
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
        height: currentStage == OrderStages.processing
            ? 760
            : currentStage == OrderStages.admin
                ? 580
                : 370,
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
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Item'),
                                              content: const Text('Are you sure you want to remove this item from the order? This will update the order totals.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(ctx);
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
                                                  },
                                                  child: const Text('Delete', style: TextStyle(color: kRedColor)),
                                                ),
                                              ],
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
                        widget.product.productSupplier?.businessName ?? '',
                        style: kColoredNameStyle,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.product.productName} (${widget.product.productCode})',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentStage == OrderStages.order ||
                              currentStage == OrderStages.processing)
                            Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                  color: currentStage == OrderStages.order &&
                                          dropdownValue == 'confirmed'
                                      ? const Color(0xFF10B981)
                                          .withOpacity(0.12)
                                      : currentStage == OrderStages.order &&
                                              dropdownValue == 'failed'
                                          ? const Color(0xFFEF4444)
                                              .withOpacity(0.12)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                      color: kNewMainColor.withOpacity(0.5),
                                      width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]),
                              padding:
                                  const EdgeInsets.only(left: 12.0, right: 8.0),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  icon: const Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: kNewMainColor,
                                        size: 20),
                                  ),
                                  hint: const Text('Status',
                                      style: TextStyle(
                                          color: kSubMainColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  borderRadius: BorderRadius.circular(12.0),
                                  dropdownColor: Colors.white,
                                  items: generateItems(
                                      widget.product.productSupplier?.admins ??
                                          [],
                                      context),
                                  value: dropdownValue,
                                  selectedItemBuilder: (BuildContext context) {
                                    OrderStages currentStage =
                                        Provider.of<OrderProvider>(context,
                                                listen: false)
                                            .currentStage;
                                    return generateItems(
                                            widget.product.productSupplier
                                                    ?.admins ??
                                                [],
                                            context)
                                        .map<Widget>((DropdownMenuItem item) {
                                      Color textColor;
                                      String displayText = '';

                                      if (item.value == 'confirmed') {
                                        textColor = const Color(0xFF10B981);
                                      } else if (item.value == 'failed' ||
                                          item.value == 'canceled') {
                                        textColor = const Color(0xFFEF4444);
                                      } else {
                                        textColor = kNewMainColor;
                                      }

                                      if (currentStage != OrderStages.order &&
                                          currentStage != OrderStages.admin) {
                                        List admins = widget.product
                                                .productSupplier?.admins ??
                                            [];
                                        var admin = admins.firstWhere(
                                            (e) => e['adminId'] == item.value,
                                            orElse: () => null);
                                        displayText = admin != null
                                            ? admin['name']
                                            : (item.value.toString())
                                                .capitalize();
                                      } else {
                                        displayText = item.value
                                            .toString()
                                            .split(' ')
                                            .map((e) => e.capitalize())
                                            .join(' ');
                                      }

                                      return Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          displayText,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'SourceSans',
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
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
                                          if (value == 'failed') {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('Mark as Out of Stock?'),
                                                content: const Text('This will mark the item as "Failed". This is a terminal state and will exclude the item from delivery calculations.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(ctx);
                                                      setState(() {
                                                        dropdownValue = widget.product.availability != null 
                                                          ? (widget.product.availability! ? 'confirmed' : 'failed')
                                                          : null;
                                                      });
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(ctx);
                                                      _executeStatusUpdate(value, onOrderOrAdminStage);
                                                    },
                                                    child: const Text('Confirm', style: TextStyle(color: kRedColor)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            _executeStatusUpdate(value, onOrderOrAdminStage);
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          // Flexible spacing is handled by SpaceBetween now. No need for fixed SizedBox except between interactive icons if they cluster
                          if (onOrderStage ||
                              currentStage == OrderStages.processing) ...[
                            if (!onPhone && !onLocation)
                              const Spacer(), // Pushes icons to the right but spaceBetween does this too. Wrap them in a Row.
                            if (onPhone || onLocation)
                              const SizedBox(width: 10.0),
                            Expanded(
                              // Text expansion if phone or loc is tapped
                              child: Text(
                                onPhone
                                    ? '+880${currentStage == OrderStages.processing ? widget.product.adminModel?.mobile : widget.product.productSupplier?.mobile ?? ''}'
                                    : onLocation
                                        ? widget.product.productSupplier
                                                ?.address ??
                                            ''
                                        : '',
                                overflow: TextOverflow.ellipsis,
                                style: kProductNameStylePro,
                                maxLines: 3,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedIconWidget(
                                  height: 40.0,
                                  width: 40.0,
                                  borderWidth: 1.5,
                                  borderRadius: 12.0,
                                  color: onPhone
                                      ? kRedColor.withOpacity(0.8)
                                      : kNewMainColor.withOpacity(0.5),
                                  onTap: (onOrderStage && !disable) ||
                                          (currentStage ==
                                                  OrderStages.processing &&
                                              !disable)
                                      ? () async {
                                          setState(() {
                                            onPhone = !onPhone;
                                            if (onLocation) onLocation = false;
                                          });
                                          if (onPhone) {
                                            String mobile =
                                                '+880${currentStage == OrderStages.processing ? widget.product.adminModel?.mobile : widget.product.productSupplier?.mobile}';
                                            final url =
                                                Uri.parse('tel:$mobile');
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            }
                                          }
                                        }
                                      : null,
                                  iconData: Icons.call,
                                ),
                                if (onOrderStage)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: OutlinedIconWidget(
                                      height: 40.0,
                                      width: 40.0,
                                      borderWidth: 1.5,
                                      borderRadius: 12.0,
                                      color: onLocation
                                          ? kRedColor.withOpacity(0.8)
                                          : kNewMainColor.withOpacity(0.5),
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
                                  ),
                              ],
                            ),
                          ],
                          if ((currentStage == OrderStages.receiving &&
                                  widget.orderInfo['receiveStatus'] ==
                                      'pending') ||
                              currentStage == OrderStages.processing ||
                              currentStage == OrderStages.delivery)
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
                              if (currentStage != OrderStages.processing)
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
                                          if (status[statusIndex] !=
                                                  'Pending' &&
                                              status[statusIndex] !=
                                                  'Success') {
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
                                                    'processingStatus':
                                                        'pending',
                                                  if (provider.currentStage ==
                                                      OrderStages.receiving)
                                                    'receiveStatus': status[
                                                                    statusIndex]
                                                                .toLowerCase() ==
                                                            'receiving'
                                                        ? 'pending'
                                                        : status[statusIndex]
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
                              return const SizedBox();
                            }),
                        ],
                      ),
                      if (currentStage == OrderStages.processing)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SET TIME DURATION",
                                style: TextStyle(
                                  color: kSubMainColor.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        _showTimerPicker(context);
                                      },
                                      child: Container(
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color:
                                              kSubMainColor.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color:
                                                kSubMainColor.withOpacity(0.1),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.stopwatch,
                                              size: 18,
                                              color: kSubMainColor
                                                  .withOpacity(0.5),
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              "${selectedDuration.inHours.toString().padLeft(2, '0')}:${(selectedDuration.inMinutes % 60).toString().padLeft(2, '0')}",
                                              style:
                                                  kProductNameStylePro.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: kSubMainColor,
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color: kSubMainColor
                                                  .withOpacity(0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      if ((currentStage == OrderStages.processing ||
                              currentStage == OrderStages.admin) &&
                          widget.product.startedAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "PROCESSING PROGRESS",
                                    style: TextStyle(
                                      color: kSubMainColor.withOpacity(0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  Text(
                                    _getTimeRemainingText(),
                                    style: const TextStyle(
                                      color: kSubMainColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _calculateProgress(),
                                  minHeight: 8,
                                  backgroundColor:
                                      kSubMainColor.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _calculateProgress() > 0.9
                                        ? Colors.red
                                        : kSubMainColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (currentStage == OrderStages.processing)
                        if (widget.product.processingStatus == 'failed' ||
                            widget.product.processingStatus == 'delayed')
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: kNewMainColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: kNewMainColor.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        widget.product.processingStatus ==
                                                'failed'
                                            ? Icons.report_problem_rounded
                                            : Icons.history_rounded,
                                        color: widget.product
                                                    .processingStatus ==
                                                'failed'
                                            ? kRedColor
                                            : kSubMainColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        widget.product.processingStatus ==
                                                'failed'
                                            ? "UNAVAILABLE - PENDING DECISION"
                                            : "DELAY REQUESTED",
                                        style: TextStyle(
                                          color: widget.product
                                                      .processingStatus ==
                                                  'failed'
                                              ? kRedColor
                                              : kSubMainColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (widget.product.note != null &&
                                      widget.product.note!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        "Reason: ${widget.product.note}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (widget.product
                                                    .processingStatus ==
                                                'failed') {
                                              final nextStatus =
                                                  'failed_accepted';
                                              productUpdate(
                                                context: context,
                                                data: {
                                                  'id': widget.product.id,
                                                  'itemInfo': {
                                                    'processingStatus':
                                                        nextStatus,
                                                  },
                                                },
                                              );
                                              Provider.of<OrderProvider>(
                                                      context,
                                                      listen: false)
                                                  .batchUpdateItemsByIds(
                                                      [widget.product.id],
                                                      processingStatus:
                                                          nextStatus);
                                            } else {
                                              _showExtensionDialog(context);
                                            }
                                          },
                                          child: Text(
                                              widget.product.processingStatus ==
                                                      'failed'
                                                  ? "CUSTOMER ACCEPTED"
                                                  : "ACCEPT EXTENSION",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kNewMainColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            _showCustomerTimerPicker(context);
                                          },
                                          child: const Text(
                                            "NEEDS TIME",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                            textAlign: TextAlign.center,
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.orange,
                                            side: const BorderSide(
                                                color: Colors.orange),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            if (widget.product
                                                    .processingStatus ==
                                                'failed') {
                                              productUpdate(
                                                context: context,
                                                data: {
                                                  'id': widget.product.id,
                                                  'itemInfo': {
                                                    'processingStatus':
                                                        'failed_canceled',
                                                  },
                                                },
                                              );
                                              Provider.of<OrderProvider>(
                                                      context,
                                                      listen: false)
                                                  .batchUpdateItemsByIds(
                                                      [widget.product.id],
                                                      processingStatus:
                                                          'failed_canceled');
                                            }
                                          },
                                          child: Text(
                                              widget.product.processingStatus ==
                                                      'failed'
                                                  ? "CANCEL ITEM"
                                                  : "REASSIGN",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 10)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: kRedColor,
                                            side: const BorderSide(
                                                color: kRedColor),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (currentStage == OrderStages.processing)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Consumer<OrderProvider>(
                              builder: (context, provider, any) {
                            bool hasNewProcessor = dropdownValue != null &&
                                dropdownValue !=
                                    widget.product.effectiveAdminId;
                            bool isButtonEnabled =
                                (!disable && hasNewProcessor) ||
                                    (!disable && onStatusChange());

                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: Builder(
                                builder: (context) {
                                  print(
                                      'DEBUG BUTTON STATE: effectiveAdminId: "${widget.product.effectiveAdminId}", dropdownValue: "$dropdownValue", hasNewProcessor: $hasNewProcessor');
                                  return ElevatedButton.icon(
                                    onPressed: isButtonEnabled
                                        ? () {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            final selectedAdmin = widget
                                                .product.supplyAdmins
                                                .cast<AdminModel?>()
                                                .firstWhere(
                                                    (a) =>
                                                        a?.adminId ==
                                                        dropdownValue,
                                                    orElse: () => null);
                                            productUpdate(
                                              context: context,
                                              data: {
                                                'id': _getRelatedProductIds(),
                                                'itemInfo': {
                                                  'adminId': dropdownValue,
                                                  'processingStatus': 'pending',
                                                },
                                              },
                                            );
                                            Provider.of<OrderProvider>(context,
                                                    listen: false)
                                                .batchUpdateSupplierItems(
                                              widget.product.supplierId,
                                              adminId: dropdownValue,
                                              adminModel: selectedAdmin,
                                              processingStatus: 'pending',
                                            );
                                          }
                                        : null,
                                    icon: const Icon(Icons.send_rounded),
                                    label: Text(
                                      (widget.product.effectiveAdminId ==
                                                      null ||
                                                  widget
                                                      .product
                                                      .effectiveAdminId!
                                                      .isEmpty) &&
                                              dropdownValue == null
                                          ? 'Not Assigned'
                                          : (widget.product.effectiveAdminId !=
                                                          null &&
                                                      widget
                                                          .product
                                                          .effectiveAdminId!
                                                          .isNotEmpty) &&
                                                  !hasNewProcessor
                                              ? 'ASSIGNED'
                                              : 'ASSIGN',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (widget.product
                                                          .effectiveAdminId ==
                                                      null ||
                                                  widget
                                                      .product
                                                      .effectiveAdminId!
                                                      .isEmpty) &&
                                              dropdownValue == null
                                          ? Colors.grey.shade400
                                          : (widget.product.effectiveAdminId !=
                                                          null &&
                                                      widget
                                                          .product
                                                          .effectiveAdminId!
                                                          .isNotEmpty) &&
                                                  !hasNewProcessor
                                              ? Colors.grey.shade400
                                              : kNewMainColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 0,
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      if (currentStage == OrderStages.admin)
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: widget.product.processingStatus == 'completed'
                              ? SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.check_circle_outline),
                                    label: const Text('COMPLETED',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade400,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                )
                              : widget.product.startedAt == null
                                  ? SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          final now = DateTime.now();
                                          productUpdate(
                                            context: context,
                                            data: {
                                              'id': _getRelatedProductIds(),
                                              'itemInfo': {
                                                'processingStatus': 'processing',
                                                'startedAt':
                                                    now.toIso8601String(),
                                              },
                                            },
                                          );
                                          Provider.of<OrderProvider>(context,
                                                  listen: false)
                                              .batchUpdateSupplierItems(
                                            widget.product.supplierId,
                                            startedAt: now,
                                            processingStatus: 'processing',
                                          );
                                        },
                                        icon: const Icon(Icons.play_arrow_rounded),
                                        label: const Text('START',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kNewMainColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              productUpdate(
                                                context: context,
                                                data: {
                                                  'id': widget.product.id,
                                                  'itemInfo': {
                                                    'processingStatus':
                                                        'completed',
                                                  },
                                                },
                                              );
                                              Provider.of<OrderProvider>(context,
                                                      listen: false)
                                                  .batchUpdateItemsByIds(
                                                      [widget.product.id],
                                                      processingStatus:
                                                          'completed');
                                            },
                                            child: const Text('COMPLETE',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF10B981),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _showDelayDialog(context),
                                            child: const Text('DELAY',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFF59E0B),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              productUpdate(
                                                context: context,
                                                data: {
                                                  'id': widget.product.id,
                                                  'itemInfo': {
                                                    'processingStatus': 'failed',
                                                  },
                                                },
                                              );
                                              Provider.of<OrderProvider>(context,
                                                      listen: false)
                                                  .batchUpdateItemsByIds(
                                                      [widget.product.id],
                                                      processingStatus:
                                                          'failed');
                                            },
                                            child: const Text('UNAVAIL.',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(0xFFEF4444),
                                              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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

  void _showTimerPicker(BuildContext context) {
    Duration tempDuration = selectedDuration;
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () {
                      setState(() {
                        selectedDuration = tempDuration;
                        isLoading = true;
                      });
                      Navigator.pop(context);
                      productUpdate(
                        context: context,
                        data: {
                          'id': _getRelatedProductIds(),
                          'itemInfo': {
                            'estimatedTime': selectedDuration.inMinutes,
                          },
                        },
                      );
                      Provider.of<OrderProvider>(context, listen: false)
                          .batchUpdateSupplierItems(
                        widget.product.supplierId,
                        estimatedTime: selectedDuration.inMinutes,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: selectedDuration,
                onTimerDurationChanged: (duration) {
                  tempDuration = duration;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerTimerPicker(BuildContext context) {
    Duration tempDuration = const Duration(hours: 2); // Default to 2 hours
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('OK'),
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      Navigator.pop(context);
                      
                      final newDeadline = DateTime.now().add(tempDuration).toIso8601String();

                      productUpdate(
                        context: context,
                        data: {
                          'id': widget.product.id,
                          'itemInfo': {
                            'customerDecisionDeadline': newDeadline,
                            'customerDecisionAlerted': false,
                          },
                        },
                      );
                      // Update local state via OrderProvider if needed, though productUpdate triggers refresh
                      Provider.of<OrderProvider>(context, listen: false)
                          .batchUpdateItemsByIds(
                            [widget.product.id],
                          );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: tempDuration,
                onTimerDurationChanged: (duration) {
                  tempDuration = duration;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startProgressTimer() {
    if ((currentStage == OrderStages.processing ||
            currentStage == OrderStages.admin) &&
        widget.product.startedAt != null) {
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _showExtensionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Additional Time Required",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Enter additional minutes for this task:",
                      style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Minutes (e.g. 15)",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNewMainColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      final additionalMins = int.tryParse(controller.text);
                      if (additionalMins != null) {
                        final now = DateTime.now();
                        final pauseDuration = now.difference(
                            widget.product.delayedAt ?? now);
                        
                        // Shift startedAt forward by the time spent in paused mode
                        final newStartedAt =
                            (widget.product.startedAt ?? now).add(pauseDuration);
                        final newEstimatedTime =
                            widget.product.estimatedTime + additionalMins;

                        productUpdate(
                          context: context,
                          data: {
                            'id': widget.product.id,
                            'itemInfo': {
                              'processingStatus': 'processing',
                              'estimatedTime': newEstimatedTime,
                              'startedAt': newStartedAt.toIso8601String(),
                              'delayedAt': null,
                              'note': null,
                            },
                          },
                        );
                        Provider.of<OrderProvider>(context, listen: false)
                            .batchUpdateItemsByIds(
                          [widget.product.id],
                          processingStatus: 'processing',
                          estimatedTime: newEstimatedTime,
                          startedAt: newStartedAt,
                        );
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text("Accept & Continue",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ));
  }

  void _showDelayDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Report Delay",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              content: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Reason for delay...",
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
                        final now = DateTime.now();
                        productUpdate(
                          context: context,
                          data: {
                            'id': widget.product.id,
                            'itemInfo': {
                              'processingStatus': 'delayed',
                              'note': controller.text,
                              'delayedAt': now.toIso8601String(),
                            },
                          },
                        );
                        Provider.of<OrderProvider>(context, listen: false)
                            .batchUpdateItemsByIds([widget.product.id],
                                processingStatus: 'delayed', delayedAt: now);
                        Navigator.pop(ctx);
                    },
                    child: const Text("Submit",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ));
  }

  double _calculateProgress() {
    if (widget.product.startedAt == null || widget.product.estimatedTime <= 0) {
      return 0.0;
    }
    final now = widget.product.processingStatus == 'delayed'
        ? (widget.product.delayedAt ?? DateTime.now())
        : DateTime.now();
    final elapsed = now.difference(widget.product.startedAt!).inSeconds;
    final total = widget.product.estimatedTime * 60;
    final progress = elapsed / total;
    return progress.clamp(0.0, 1.0);
  }

  String _getTimeRemainingText() {
    if (widget.product.startedAt == null || widget.product.estimatedTime <= 0) {
      return "";
    }
    final isPaused = widget.product.processingStatus == 'delayed';
    final now = isPaused
        ? (widget.product.delayedAt ?? DateTime.now())
        : DateTime.now();
    final total = widget.product.estimatedTime * 60;
    final elapsed = now.difference(widget.product.startedAt!).inSeconds;
    final remaining = total - elapsed;

    if (remaining <= 0) return "OVERDUE";
    if (isPaused) {
      final duration = Duration(seconds: remaining);
      return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, "0")} PAUSED";
    }

    final duration = Duration(seconds: remaining);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inDays > 0) {
      String twoDigitHours = twoDigits(duration.inHours.remainder(24));
      return "${twoDigits(duration.inDays)}:$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds LEFT";
    } else if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds LEFT";
    } else {
      return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds LEFT";
    }
  }

  void _executeStatusUpdate(dynamic value, bool onOrderOrAdminStage) {
    setState(() {
      dropdownValue = (value ?? '') as String?;
      if (onOrderOrAdminStage) {
        isLoading = true;
      }
    });

    if (onOrderOrAdminStage) {
      if (currentStage == OrderStages.admin &&
          (value == 'mark as complete' || value == 'report delay')) {
        if (value == 'mark as complete') {
          productUpdate(
            context: context,
            data: {
              'id': widget.product.id,
              'itemInfo': {
                'processingStatus': 'completed',
              },
            },
          );
        } else {
          _showDelayDialog(context);
        }
        setState(() {
          isLoading = false;
        });
      } else {
        productUpdate(
          context: context,
          data: {
            'id': widget.product.id,
            'itemInfo': {
              if (onOrderStage) 'availability': value == 'confirmed',
              if (currentStage == OrderStages.admin) 'processingStatus': value,
            },
          },
        );
      }
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
    this.borderRadius = 7.0,
  }) : super(key: key);

  final IconData iconData;
  final void Function()? onTap;
  final double? height;
  final double? width;
  final Color color;
  final double borderWidth;
  final double borderRadius;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
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
    List admins, BuildContext context) {
  List<DropdownMenuItem<String>> items = [];
  OrderStages currentStage = Provider.of<OrderProvider>(context).currentStage;
  if (currentStage == OrderStages.order || currentStage == OrderStages.admin) {
    List<String> titles = currentStage == OrderStages.admin
        ? ['Mark As Complete', 'Report Delay']
        : ['Confirmed', 'Failed'];
    items = titles.map((e) {
      Color textColor;
      Color bgColor = Colors.transparent;
      if (e == 'Confirmed') {
        textColor = const Color(0xFF10B981); // Emerald Green
        bgColor = const Color(0xFF10B981).withOpacity(0.1);
      } else if (e == 'Failed' || e == 'Canceled') {
        textColor = const Color(0xFFEF4444); // Red
        bgColor = const Color(0xFFEF4444).withOpacity(0.1);
      } else {
        textColor = const Color(0xFFF59E0B); // Amber for Pending
        bgColor = const Color(0xFFF59E0B).withOpacity(0.1);
      }
      return DropdownMenuItem<String>(
        value: e.toLowerCase(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            e,
            style: TextStyle(
              color: textColor,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'SourceSans',
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }).toList();
  } else {
    items = admins.map((e) {
      return DropdownMenuItem<String>(
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
