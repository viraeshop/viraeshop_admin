import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/date/my_date_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/on_error_widget.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/order_chips.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/totalOrderDetailsCard.dart';
import 'package:dart_date/dart_date.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/userTotalOrdersDetailsCard.dart';
import 'package:viraeshop_admin/screens/customers/tabWidgets.dart';
import 'package:viraeshop_admin/screens/orders/customer_orders.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';

import '../../reusable_widgets/loading_widget.dart';
import '../../reusable_widgets/orders/functions.dart';
import '../../reusable_widgets/orders/order_date_widget.dart';
import '../../reusable_widgets/orders/order_dropdown.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String deliveryAndReceiveStatus = 'receiveStatus';
  String status = 'pending';
  DateTime beginDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Map<String, dynamic> totalReport = {};
  List<Map<String, dynamic>> customersTotalOrdersInfo = [];
  List<String> statusList = ['Pending', 'Completed', 'Failed'];
  bool isLoading = true;
  bool onDateSelected = false;
  bool onError = false;
  String errorMessage = '';
  int offset = 0;
  Map<String, dynamic> data = {};
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    DateTime today = DateTime.now();
    data = {
      'monthBegin': today.startOfMonth.toIso8601String(),
      'monthEnd': today.endOfMonth.toIso8601String(),
      'weekBegin': today.startOfWeek.toIso8601String(),
      'weekEnd': today.endOfWeek.toIso8601String(),
      'today': today.toIso8601String(),
      'isFilter': true,
      'filterType': 'receiving',
    };
    final orderBloc = BlocProvider.of<OrdersBloc>(context);
    orderBloc.add(GetOrderDetailsEvent(token: jWTToken, data: data));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(FontAwesomeIcons.chevronLeft),
          color: kBlackColor,
        ),
        title: const Text(
          'Delivery',
          style: kTotalSalesStyle,
        ),
        centerTitle: true,
      ),
      body: BlocListener<OrdersBloc, OrderState>(
        listenWhen: (prevState, currentState) {
          if (isLoading) {
            return true;
          } else {
            return false;
          }
        },
        listener: (context, state) {
          if (state is FetchedOrderDetailsState) {
            setState(() {
              totalReport = state.orderDetails;
              isLoading = false;
            });
          } else if (state is OnErrorOrderState) {
            setState(() {
              isLoading = false;
              onError = true;
              errorMessage = state.message;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: screenSize.height,
          width: screenSize.width,
          child: totalReport.isEmpty
              ? const LoadingWidget()
              : onError
                  ? OnErrorWidget(
                      message: errorMessage,
                    )
                  : Column(
                      children: [
                        TotalOrderDetailsCard(
                          dailyAmount: totalReport['daily']['dailyAmount'] ?? 0,
                          dailyOrders: totalReport['daily']['count'],
                          weeklyAmount:
                              totalReport['weekly']['weeklyAmount'] ?? 0,
                          weeklyOrders: totalReport['weekly']['count'],
                          monthlyAmount:
                              totalReport['monthly']['monthlyAmount'] ?? 0,
                          monthlyOrders: totalReport['monthly']['count'],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 10.0,
                              height: 50.0,
                              child: Checkbox(
                                value: onDateSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    onDateSelected = value!;
                                    beginDate = DateTime.now();
                                    endDate = DateTime.now();
                                  });
                                },
                                activeColor: kNewMainColor,
                                checkColor: kBackgroundColor,
                              ),
                            ),
                            const SizedBox(
                              width: 2.0,
                            ),
                            OrderDateWidget(
                              color: !onDateSelected
                                  ? kNewMainColor.withOpacity(0.2)
                                  : kNewMainColor,
                              date: beginDate.toString().split(' ')[0],
                              onTap: !onDateSelected
                                  ? null
                                  : () async {
                                      final result =
                                          await myDatePicker(context);
                                      setState(() {
                                        beginDate = result;
                                      });
                                    },
                            ),
                            OrderDateWidget(
                              color: !onDateSelected
                                  ? kNewMainColor.withOpacity(0.2)
                                  : kNewMainColor,
                              date: endDate.toString().split(' ')[0],
                              onTap: !onDateSelected
                                  ? null
                                  : () async {
                                      final result =
                                          await myDatePicker(context);
                                      setState(() {
                                        endDate = result;
                                        offset = 0;
                                      });
                                      Map<String, dynamic> filterInfo = {
                                        'filterType': deliveryAndReceiveStatus,
                                        'filterData': {
                                          'status': status,
                                          'date': {
                                            'startDate':
                                                beginDate.toIso8601String(),
                                            'endDate':
                                                endDate.toIso8601String(),
                                          },
                                        },
                                        'offSet': offset,
                                      };
                                      // ignore: use_build_context_synchronously
                                      getOrders(
                                        data: filterInfo,
                                        context: context,
                                      );
                                      // ignore: use_build_context_synchronously
                                      Provider.of<OrderProvider>(context,
                                              listen: false)
                                          .updateFilterInfo(filterInfo);
                                    },
                            ),
                            OrderDropdown(
                              value: deliveryAndReceiveStatus,
                              onChanged: (String? value) {
                                setState(() {
                                  deliveryAndReceiveStatus = value ?? '';
                                  offset = 0;
                                });
                                Map<String, dynamic> filterInfo = {
                                  'filterType': deliveryAndReceiveStatus,
                                  'filterData': {
                                    'status': status,
                                    if (onDateSelected)
                                      'date': {
                                        'startDate':
                                            beginDate.toIso8601String(),
                                        'endDate': endDate.toIso8601String(),
                                      },
                                  },
                                  'offSet': offset,
                                };
                                if (deliveryAndReceiveStatus ==
                                    'receiveStatus') {
                                  getOrders(
                                    data: filterInfo,
                                    context: context,
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateFilterInfo(filterInfo);
                                  Provider.of<OrderProvider>(context,
                                      listen: false)
                                      .updateOrderStage(OrderStages.receiving);
                                } else {
                                  data['filterType'] = 'delivery';
                                  final orderBloc =
                                      BlocProvider.of<OrdersBloc>(context);
                                  orderBloc.add(GetOrderDetailsEvent(
                                      token: jWTToken, data: data));
                                  setState(() {
                                    isLoading = true;
                                    totalReport.clear();
                                  });
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateOrderStage(OrderStages.delivery);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Consumer<OrderProvider>(
                            builder: (context, provider, any) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              statusList.length,
                              (index) => OrderChips(
                                width: 140.0,
                                title: statusList[index],
                                isSelected:
                                    status == statusList[index].toLowerCase(),
                                onTap: () {
                                  setState(() {
                                    status = statusList[index].toLowerCase();
                                    offset = 0;
                                  });
                                  Map<String, dynamic> filterInfo = {
                                    'filterType': deliveryAndReceiveStatus,
                                    'filterData': {
                                      'status': status,
                                      if (onDateSelected)
                                        'date': {
                                          'startDate':
                                              beginDate.toIso8601String(),
                                          'endDate': endDate.toIso8601String(),
                                        },
                                    },
                                    'offSet': offset,
                                  };
                                  getOrders(
                                    data: filterInfo,
                                    context: context,
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateFilterInfo(filterInfo);
                                },
                              ),
                            ),
                          );
                        }),
                        const SizedBox(
                          height: 20.0,
                        ),
                        LimitedBox(
                          maxHeight: screenSize.height * 0.45,
                          child: const OrdersTab(),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

void getCustomersTotalOrdersInfo(
    {required BuildContext context,
    required String token,
    required Map<String, dynamic> data}) {
  final orderBloc = BlocProvider.of<OrdersBloc>(context);
  orderBloc.add(GetCustomersTotalOrdersInfoEvent(
    token: token,
    data: data,
  ));
}
