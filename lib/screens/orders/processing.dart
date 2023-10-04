import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop/orders/barrel.dart';
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

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({Key? key}) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String processingStatus = 'all';
  DateTime beginDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String role = 'all';
  Map<String, dynamic> totalReport = {};
  List<Map<String, dynamic>> customersTotalOrdersInfo = [];
  bool isLoading = false;
  bool onDateSelected = false;
  bool onError = false;
  String errorMessage = '';
  int offset = 0;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    DateTime today = DateTime.now();
    Map<String, dynamic> data = {
      'monthBegin': today.startOfMonth.toIso8601String(),
      'monthEnd': today.endOfMonth.toIso8601String(),
      'weekBegin': today.startOfWeek.toIso8601String(),
      'weekEnd': today.endOfWeek.toIso8601String(),
      'today': today.toIso8601String(),
      'isFilter': true,
      'filterType': 'processing',
    };
    if (kDebugMode) {
      print(data);
    }
    final orderBloc = BlocProvider.of<OrdersBloc>(context);
    orderBloc.add(GetOrderDetailsEvent(token: jWTToken, data: data));
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
          'Processing',
          style: kTotalSalesStyle,
        ),
        centerTitle: true,
      ),
      body: BlocListener<OrdersBloc, OrderState>(
        listener: (context, state) {
          if (state is FetchedOrderDetailsState) {
            setState(() {
              totalReport = state.orderDetails;
              isLoading = true;
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
                                        isLoading = true;
                                        offset = 0;
                                      });
                                      Map<String, dynamic> filterInfo = {
                                        'filterType': 'processingStatus',
                                        'filterData': {
                                          'isAll': processingStatus == 'all',
                                          'date': {
                                            'startDate':
                                                beginDate.toIso8601String(),
                                            'endDate':
                                                endDate.toIso8601String(),
                                          },
                                          if (processingStatus != 'all')
                                            'status': processingStatus,
                                          if (role != 'all') 'role': role,
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
                              value: processingStatus,
                              onChanged: (String? value) {
                                setState(() {
                                  processingStatus = value ?? '';
                                  isLoading = true;
                                  offset = 0;
                                });
                                Map<String, dynamic> filterInfo = {
                                  'filterType': 'processingStatus',
                                  'filterData': {
                                    'isAll': processingStatus == 'all',
                                    if (onDateSelected)
                                      'date': {
                                        'startDate':
                                            beginDate.toIso8601String(),
                                        'endDate': endDate.toIso8601String(),
                                      },
                                    if (processingStatus != 'all')
                                      'status': processingStatus,
                                    if (role != 'all') 'role': role,
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
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Consumer<OrderProvider>(
                            builder: (context, provider, any) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OrderChips(
                                width: 100.0,
                                title: 'All',
                                isSelected: role == 'all',
                                onTap: () {
                                  setState(() {
                                    role = 'all';
                                    isLoading = true;
                                    offset = 0;
                                    processingStatus = 'all';
                                    onDateSelected = false;
                                  });
                                  Map<String, dynamic> filterInfo = {
                                    'filterType': 'processingStatus',
                                    'filterData': {
                                      'isAll': processingStatus == 'all',
                                    },
                                    'offSet': offset,
                                  };
                                  // ignore: use_build_context_synchronously
                                  getOrders(
                                    data: filterInfo,
                                    context: context,
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateFilterInfo(filterInfo);
                                },
                              ),
                              OrderChips(
                                width: 100.0,
                                title: 'General',
                                isSelected: role == 'general',
                                onTap: () {
                                  setState(() {
                                    role = 'general';
                                    isLoading = true;
                                    offset = 0;
                                  });
                                  Map<String, dynamic> filterInfo = {
                                    'filterType': 'processingStatus',
                                    'filterData': {
                                      'isAll': processingStatus == 'all',
                                      if (onDateSelected)
                                        'date': {
                                          'startDate':
                                              beginDate.toIso8601String(),
                                          'endDate': endDate.toIso8601String(),
                                        },
                                      if (processingStatus != 'all')
                                        'status': processingStatus,
                                      'role': role,
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
                              OrderChips(
                                width: 100.0,
                                title: 'Agents',
                                isSelected: role == 'agents',
                                onTap: () {
                                  setState(() {
                                    role = 'agents';
                                    isLoading = true;
                                    offset = 0;
                                  });
                                  final Map<String, dynamic> filterInfo =  {
                                    'filterType': 'processingStatus',
                                    'filterData': {
                                      'isAll': processingStatus == 'all',
                                      if (onDateSelected)
                                        'date': {
                                          'startDate':
                                          beginDate.toIso8601String(),
                                          'endDate':
                                          endDate.toIso8601String(),
                                        },
                                      if (processingStatus != 'all')
                                        'status': processingStatus,
                                      'role': role,
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
                              OrderChips(
                                width: 100.0,
                                title: 'Architect',
                                isSelected: role == 'architect',
                                onTap: () {
                                  setState(() {
                                    role = 'architect';
                                    isLoading = true;
                                    offset = 0;
                                  });
                                  final Map<String, dynamic> filterInfo = {
                                    'filterType': 'processingStatus',
                                    'filterData': {
                                      'isAll': processingStatus == 'all',
                                      if (onDateSelected)
                                        'date': {
                                          'startDate':
                                          beginDate.toIso8601String(),
                                          'endDate':
                                          endDate.toIso8601String(),
                                        },
                                      if (processingStatus != 'all')
                                        'status': processingStatus,
                                      'role': role,
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
                            ],
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
