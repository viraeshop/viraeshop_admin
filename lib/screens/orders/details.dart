import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_api/models/items/items.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_bloc/admin/barrel.dart';
import 'package:viraeshop_bloc/transactions/transactions_bloc.dart';
import 'package:viraeshop_bloc/transactions/transactions_state.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/delivery_timer.dart';
import 'package:viraeshop_api/models/orders/orders.dart';

import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';

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
  List<AdminModel> deliveryAgents = [];
  AdminModel? selectedAgent;
  DateTime? estimatedArrival;
  Duration selectedDuration = const Duration(hours: 3);
  bool _shouldPopOnSuccess = true;
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
    final provider = Provider.of<OrderProvider>(context, listen: false);
    deliveryFeeController.text = provider.deliveryFee.toString();
    discountController.text = provider.discount.toString();
    advanceController.text = provider.advance.toString();

    // Fetch admins to get delivery agents
    final adminBloc = BlocProvider.of<AdminBloc>(context);
    adminBloc.add(GetAdminsEvent(token: jWTToken));

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
                  if (_shouldPopOnSuccess) {
                    Navigator.pop(context);
                  } else {
                    _shouldPopOnSuccess = true; // reset
                  }
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
            BlocListener<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is FetchedAdminsState) {
                  setState(() {
                    deliveryAgents = (state.adminList ?? [])
                        .where((admin) => admin.canDeliverOrders == true)
                        .toList();

                    // Pre-select if already assigned
                    if (widget.orderInfo['deliveryBoyId'] != null) {
                      try {
                        selectedAgent = deliveryAgents.firstWhere((element) =>
                            element.adminId ==
                            widget.orderInfo['deliveryBoyId']);
                      } catch (e) {
                        // Not found or not in list
                      }
                    }
                  });
                }
              },
            ),
          ],
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: screenSize.height,
            width: screenSize.width,
            color: const Color(0xffF9F9F9),
            child: SingleChildScrollView(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.customerInfo['name'],
                                style: kColoredNameStyle,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    onEditCustomerInfo = !onEditCustomerInfo;
                                  });
                                  if (onEditCustomerInfo &&
                                      widget.orderInfo['shippingAddress'] !=
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
                  Consumer<OrderProvider>(builder: (context, provider, any) {
                    return Column(
                      children: [
                        TextRow(
                          orderId: widget.orderInfo['orderId'].toString(),
                          title: 'Original Price',
                          isEditable: false,
                          subTitle: '${provider.total}',
                        ),
                        TextRow(
                          orderId: widget.orderInfo['orderId'].toString(),
                          title: 'Discount',
                          controller: discountController,
                          subTitle: '${provider.discount}',
                        ),
                        TextRow(
                          orderId: widget.orderInfo['orderId'].toString(),
                          title: 'Sub-Total',
                          isEditable: false,
                          subTitle: '${provider.subTotal}',
                        ),
                        TextRow(
                          orderId: widget.orderInfo['orderId'].toString(),
                          title: 'Delivery Fee',
                          controller: deliveryFeeController,
                          subTitle: '${provider.deliveryFee}',
                        ),
                        TextRow(
                          orderId: widget.orderInfo['orderId'].toString(),
                          title: 'Grand Total',
                          isEditable: false,
                          subTitle: '${provider.totalAmount}',
                        ),
                        TextRow(
                          orderId: widget.orderInfo['orderId'].toString(),
                          title: 'Advance',
                          controller: advanceController,
                          subTitle: '${provider.advance}',
                        ),
                        TextRow(
                          orderId: widget.orderInfo['orderId'].toString(),
                          title: 'Due',
                          isEditable: false,
                          subTitle: '${provider.due}',
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                      ],
                    );
                  }),
                  // Assign Delivery Agent Section
                  if (Provider.of<OrderProvider>(context, listen: false)
                              .currentStage ==
                          OrderStages.delivery ||
                      Provider.of<OrderProvider>(context, listen: false)
                              .currentStage ==
                          OrderStages.receiving)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assignment',
                          style: kSansTextStyleBigBlack,
                        ),
                        const SizedBox(height: 10.0),

                        // Delivery Timer for Admins
                        (() {
                          try {
                            final ordersObj = Orders.fromJson(widget.orderInfo);
                            final deliveryTask = ordersObj.deliveryTask;
                            if (deliveryTask != null &&
                                (deliveryTask.taskStatus == 'active' ||
                                    deliveryTask.taskStatus == 'pending')) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Center(
                                    child: DeliveryTimer(task: deliveryTask)),
                              );
                            }
                          } catch (e) {
                            debugPrint("Error parsing orders for timer: $e");
                          }
                          return const SizedBox.shrink();
                        })(),

                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(color: const Color(0xffE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SELECT DELIVERY PERSON',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xffE2E8F0)),
                                ),
                                child: DropdownButtonFormField<AdminModel>(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(Icons.person,
                                        color: Color(0xff94A3B8), size: 20),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      color: Color(0xff64748B)),
                                  value: selectedAgent,
                                  hint: const Text('Select Agent',
                                      style:
                                          TextStyle(color: Color(0xff94A3B8))),
                                  items: deliveryAgents.map((agent) {
                                    return DropdownMenuItem<AdminModel>(
                                      value: agent,
                                      child: Text('${agent.name} (Active)',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff1E293B))),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAgent = value;
                                    });
                                    if (value != null) {
                                      Provider.of<OrderProvider>(context,
                                              listen: false)
                                          .updateOrderInfo(
                                              'deliveryBoyId', value.adminId);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'EXPECTED DELIVERY TIME',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => _showTimerPicker(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xffE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_filled,
                                          color: Color(0xff94A3B8), size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${selectedDuration.inHours} Hours',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff1E293B),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              InkWell(
                                onTap: selectedAgent == null
                                    ? null
                                    : () {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        final arrivalTime = DateTime.now()
                                            .add(selectedDuration);
                                        final orderBloc =
                                            BlocProvider.of<OrdersBloc>(
                                                context);

                                        Map<String, dynamic> updateData = {
                                          'orderStage': 'delivery',
                                          'notificationType': 'admin2Employee',
                                          'deliveryBoyId':
                                              selectedAgent?.adminId,
                                          'estimatedArrival':
                                              arrivalTime.toIso8601String(),
                                          'durationMinutes':
                                              selectedDuration.inMinutes,
                                          'deliveryStatus': 'assigned'
                                        };

                                        orderBloc.add(
                                          UpdateOrderEvent(
                                            orderId: widget.orderInfo['orderId']
                                                .toString(),
                                            orderModel: updateData,
                                            token: jWTToken,
                                          ),
                                        );
                                      },
                                child: Container(
                                  height: 56,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: selectedAgent == null
                                        ? Colors.grey
                                        : const Color(0xff10B981),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      if (selectedAgent != null)
                                        BoxShadow(
                                          color: const Color(0xff10B981)
                                              .withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.local_shipping,
                                          color: Colors.white),
                                      SizedBox(width: 12),
                                      Text(
                                        'Start Delivery Run',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: (widget.orderInfo['orderStatus'] == 'success' ||
                (Provider.of<OrderProvider>(context, listen: false)
                            .currentStage !=
                        OrderStages.delivery &&
                    Provider.of<OrderProvider>(context, listen: false)
                            .currentStage !=
                        OrderStages.receiving))
            ? SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: widget.orderInfo['orderStatus'] == 'success'
                      ? const Text(
                          'Order Delivered Successfully..',
                          style: kProductNameStylePro,
                          textAlign: TextAlign.center,
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatusButton(
                                  title: 'Confirmed',
                                  color: Colors.green.shade600,
                                  onTap: () => _handleStatusAction('confirmed'),
                                ),
                                _buildStatusButton(
                                  title: 'Pending',
                                  color: Colors.orange.shade600,
                                  onTap: () => _handleStatusAction('pending'),
                                ),
                                _buildStatusButton(
                                  title: 'Canceled',
                                  color: Colors.red.shade600,
                                  onTap: () => _handleStatusAction('canceled'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Consumer<OrderProvider>(
                                builder: (context, provider, any) {
                              if (provider.currentStage == OrderStages.order ||
                                  provider.currentStage ==
                                      OrderStages.delivery) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(
                                          0xFF0D9488), // Teal/Green Custom Solid
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () {
                                      if (deliveryFeeController
                                          .text.isNotEmpty) {
                                        provider.updateValue(
                                          updatingValue: Values.deliveryFee,
                                          values: {
                                            'deliveryFee': num.tryParse(
                                                    deliveryFeeController
                                                        .text) ??
                                                0
                                          },
                                        );
                                      }
                                      if (discountController.text.isNotEmpty) {
                                        provider.updateValue(
                                          updatingValue: Values.discount,
                                          values: {
                                            'discount': num.tryParse(
                                                    discountController.text) ??
                                                0
                                          },
                                        );
                                      }
                                      if (advanceController.text.isNotEmpty) {
                                        provider.updateValue(
                                          updatingValue: Values.advance,
                                          values: {
                                            'advance': num.tryParse(
                                                    advanceController.text) ??
                                                0
                                          },
                                        );
                                      }

                                      setState(() {
                                        isLoading = true;
                                        _shouldPopOnSuccess = false;
                                      });
                                      final orderBloc =
                                          BlocProvider.of<OrdersBloc>(context,
                                              listen: false);
                                      orderBloc.add(
                                        UpdateOrderEvent(
                                          orderId: widget.orderInfo['orderId']
                                              .toString(),
                                          orderModel: provider.orderInfo,
                                          token: jWTToken,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Update',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildStatusButton(
      {required String title,
      required Color color,
      required VoidCallback onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onTap,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _handleStatusAction(String status) {
    setState(() {
      isLoading = true;
      _shouldPopOnSuccess = true;
    });

    final orderBloc = BlocProvider.of<OrdersBloc>(context, listen: false);
    print('status: $status');
    Map<String, dynamic> data = {
      'orderStage': 'order',
      'notificationType': 'admin2Customer',
      'orderStatus': status,
      'adminId': adminId,
      if (status == 'confirmed') 'processingStatus': 'pending',
      if (status == 'confirmed') 'incrementProcessingCount': true,
    };

    orderBloc.add(
      UpdateOrderEvent(
        orderId: widget.orderInfo['orderId'].toString(),
        orderModel: data,
        token: jWTToken,
      ),
    );
  }

  void _showTimerPicker(BuildContext context) {
    Duration tempDuration = selectedDuration;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      setState(() {
                        selectedDuration = tempDuration;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: selectedDuration,
                onTimerDurationChanged: (Duration newDuration) {
                  tempDuration = newDuration;
                },
              ),
            ),
          ],
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
    required this.orderId,
  }) : super(key: key);
  final String title;
  final bool isEditable;
  final String? subTitle;
  final TextEditingController? controller;
  final String orderId;

  @override
  State<TextRow> createState() => _TextRowState();
}

class _TextRowState extends State<TextRow> {
  bool onEdit = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && mounted && onEdit) {
        setState(() {
          onEdit = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _syncToProvider(String value) {
    Values? valType;
    String key = '';

    if (widget.title == 'Delivery Fee') {
      valType = Values.deliveryFee;
      key = 'deliveryFee';
    } else if (widget.title == 'Discount') {
      valType = Values.discount;
      key = 'discount';
    } else if (widget.title == 'Advance') {
      valType = Values.advance;
      key = 'advance';
    }

    if (valType != null) {
      num parseVal = num.tryParse(value) ?? 0;
      context
          .read<OrderProvider>()
          .updateValue(updatingValue: valType, values: {
        key: parseVal,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGrandTotal = widget.title == 'Grand Total';

    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 6.0, horizontal: 10.0), // subtle padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget.title}:',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: isGrandTotal ? Colors.black87 : Colors.grey.shade600,
              fontWeight: isGrandTotal ? FontWeight.w700 : FontWeight.w600,
              fontSize: isGrandTotal ? 16 : 14,
            ),
          ),
          SizedBox(
            width:
                130, // strictly enforce width to trap values in a rigid column
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: onEdit
                      ? TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          textAlign: TextAlign.right,
                          onChanged: _syncToProvider,
                          onTap: () {
                            if (widget.controller?.text == '0' ||
                                widget.controller?.text == '0.0') {
                              widget.controller?.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: widget.controller!.text.length,
                              );
                            }
                          },
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isGrandTotal
                                ? const Color(0xFF0D9488)
                                : Colors.black,
                            fontWeight: isGrandTotal
                                ? FontWeight.w800
                                : FontWeight.w700,
                            fontSize: isGrandTotal ? 18 : 15,
                          ),
                          cursorColor: kNewMainColor,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        )
                      : Text(
                          '${widget.isEditable ? widget.controller!.text : widget.subTitle}$bdtSign',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: isGrandTotal
                                ? const Color(0xFF0D9488)
                                : Colors.black,
                            fontWeight: isGrandTotal
                                ? FontWeight.w800
                                : FontWeight.w700,
                            fontSize: isGrandTotal ? 18 : 15,
                          ),
                        ),
                ),
                SizedBox(
                  width:
                      35, // rigidly lock the edit icon spacing so non-editable rows don't collapse leftwards
                  child: (!onEdit && widget.isEditable)
                      ? Transform.translate(
                          offset: const Offset(
                              4, 0), // neatly dock against right edge
                          child: IconButton(
                            onPressed: () {
                              if (widget.controller?.text == '0' ||
                                  widget.controller?.text == '0.0') {
                                widget.controller?.clear();
                              }
                              setState(() {
                                onEdit = true;
                              });
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          )
        ],
      ),
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
        height: 100.0,
        width: 100.0,
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
