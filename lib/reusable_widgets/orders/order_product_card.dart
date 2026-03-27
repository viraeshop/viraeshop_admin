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
            ? 577
            : currentStage == OrderStages.admin
                ? 440
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
                        mainAxisAlignment: currentStage == OrderStages.order
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceEvenly,
                        children: [
                          if (currentStage == OrderStages.order ||
                              currentStage == OrderStages.processing)
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
                                      widget.product.productSupplier?.admins ??
                                          [],
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
                                            if (currentStage ==
                                                    OrderStages.admin &&
                                                (value == 'mark as complete' ||
                                                    value == 'report delay')) {
                                              if (value == 'mark as complete') {
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
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          if (onOrderStage ||
                              currentStage == OrderStages.processing)
                            OutlinedIconWidget(
                              onTap: (onOrderStage && !disable) ||
                                      (currentStage == OrderStages.processing &&
                                          !disable)
                                  ? () async {
                                      setState(() {
                                        onPhone = !onPhone;
                                        if (onLocation) onLocation = false;
                                      });
                                      if (onPhone) {
                                        String mobile =
                                            '+880${currentStage == OrderStages.processing ? widget.product.adminModel?.mobile : widget.product.productSupplier?.mobile}';
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
                          if (onPhone &&
                              (onOrderStage ||
                                  currentStage == OrderStages.processing))
                            Expanded(
                              child: Text(
                                '+880${currentStage == OrderStages.processing ? widget.product.adminModel?.mobile : widget.product.productSupplier?.mobile ?? ''}',
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
                                widget.product.productSupplier?.address ?? '',
                                overflow: TextOverflow.ellipsis,
                                style: kProductNameStylePro,
                                maxLines: 3,
                              ),
                            ),
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
                      if (currentStage == OrderStages.processing &&
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
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: widget.product.processingStatus == 'completed'
                                  ? null
                                  : () {
                                      if (widget.product.startedAt == null) {
                                        final now = DateTime.now();
                                        productUpdate(
                                          context: context,
                                          data: {
                                            'id': _getRelatedProductIds(),
                                            'itemInfo': {
                                              'processingStatus': 'processing',
                                              'startedAt': now.toIso8601String(),
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
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProcessingTimerScreen(
                                            product: widget.product,
                                            orderId: widget.orderId,
                                          ),
                                        ),
                                      ).then((_) => setState(() {}));
                                    },
                              icon: Icon(
                                widget.product.processingStatus == 'completed'
                                    ? Icons.check_circle_outline
                                    : widget.product.startedAt == null
                                        ? Icons.play_arrow_rounded
                                        : Icons.timer_outlined,
                              ),
                              label: Text(
                                widget.product.processingStatus == 'completed'
                                    ? 'Completed'
                                    : widget.product.startedAt == null
                                        ? 'START'
                                        : 'PROCESSING',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.product
                                            .processingStatus ==
                                        'completed'
                                    ? Colors.grey.shade400
                                    : widget.product.startedAt == null
                                        ? kNewMainColor
                                        : kSubMainColor,
                                disabledBackgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white70,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                            ),
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

  void _startProgressTimer() {
    if (currentStage == OrderStages.processing &&
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
                      if (controller.text.isNotEmpty) {
                        productUpdate(
                          context: context,
                          data: {
                            'id': widget.product.id,
                            'itemInfo': {
                              'processingStatus': 'delayed',
                              'note': controller.text,
                            },
                          },
                        );
                        Navigator.pop(ctx);
                      }
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
    final now = DateTime.now();
    final elapsed = now.difference(widget.product.startedAt!).inSeconds;
    final total = widget.product.estimatedTime * 60;
    final progress = elapsed / total;
    return progress.clamp(0.0, 1.0);
  }

  String _getTimeRemainingText() {
    if (widget.product.startedAt == null || widget.product.estimatedTime <= 0) {
      return "";
    }
    final now = DateTime.now();
    final total = widget.product.estimatedTime * 60;
    final elapsed = now.difference(widget.product.startedAt!).inSeconds;
    final remaining = total - elapsed;

    if (remaining <= 0) return "OVERDUE";

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
    List<String> titles = currentStage == OrderStages.admin
        ? ['Mark As Complete', 'Report Delay']
        : ['Confirmed', 'Failed'];
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

