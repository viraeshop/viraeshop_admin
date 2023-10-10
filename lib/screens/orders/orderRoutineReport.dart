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
import '../../reusable_widgets/orders/order_date_widget.dart';
import '../../reusable_widgets/orders/order_dropdown.dart';

enum Event {
  orderDetails,
  customerTotalOrdersInfo,
  updateCustomerTotalOrdersInfoList
}

// enum Filter { off, date, role, status }

class OrderRoutineReport extends StatefulWidget {
  const OrderRoutineReport({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<OrderRoutineReport> createState() => _OrderRoutineReportState();
}

class _OrderRoutineReportState extends State<OrderRoutineReport> {
  String orderStatus = 'all';
  DateTime beginDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String role = 'all';
  Map<String, dynamic> totalReport = {};
  List<Map<String, dynamic>> customersTotalOrdersInfo = [];
  bool isLoading = false;
  bool onDateSelected = false;
  bool onError = false;
  Event currentEvent = Event.orderDetails;
  //Filter currentFilter = Filter.off;
  String errorMessage = '';
  int offset = 0;
  final jWTToken = Hive.box('adminInfo').get('token');
  final ScrollController _scrollController = ScrollController();
  bool isProductEnd = false;
  @override
  void initState() {
    // TODO: implement initState
    if (widget.title == 'Processing') {
      orderStatus = 'pending';
    } else if (widget.title == 'Delivery') {
      orderStatus = 'received';
    }
    DateTime today = DateTime.now();
    Map<String, dynamic> data = {
      'monthBegin': today.startOfMonth.toIso8601String(),
      'monthEnd': today.endOfMonth.toIso8601String(),
      'weekBegin': today.startOfWeek.toIso8601String(),
      'weekEnd': today.endOfWeek.toIso8601String(),
      'today': today.toIso8601String(),
    };
    if (kDebugMode) {
      print(data);
    }
    final orderBloc = BlocProvider.of<OrdersBloc>(context);
    orderBloc.add(GetOrderDetailsEvent(token: jWTToken, data: data));
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0 && !isProductEnd) {
        _fetchMoreProducts();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  _fetchMoreProducts() {
    setState(() {
      isLoading = true;
      currentEvent = Event.updateCustomerTotalOrdersInfoList;
      offset += 20;
    });
    Map<String, dynamic> filters = {
      if (onDateSelected)
        'date': {
          'startDate': beginDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      if (orderStatus != 'all') 'status': orderStatus,
      if (role != 'all') 'role': role,
    };
    bool filterActive = onDateSelected || orderStatus != 'all' || role != 'all';
    final orderBloc = BlocProvider.of<OrdersBloc>(context);
    orderBloc.add(GetCustomersTotalOrdersInfoEvent(
      token: jWTToken,
      data: {
        'filter': {
          'active': filterActive,
          if (filterActive)
            'filterInfo': {
              'filterLength': filters.length,
              'filters': filters,
            },
        },
        'offset': offset,
      },
    ));
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
        title: Text(
          widget.title,
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
              currentEvent = Event.customerTotalOrdersInfo;
            });
            final orderBloc = BlocProvider.of<OrdersBloc>(context);
            orderBloc.add(GetCustomersTotalOrdersInfoEvent(
              token: jWTToken,
              data: const {
                'filter': {
                  'active': false,
                },
              },
            ));
          } else if (state is FetchedCustomersTotalOrdersInfoState) {
            setState(() {
              isLoading = false;
              // if (kDebugMode) {
              //   print(state.customersTotalOrdersInfo);
              // }
              if (currentEvent == Event.customerTotalOrdersInfo) {
                customersTotalOrdersInfo = state.customersTotalOrdersInfo;
              } else {
                if (state.customersTotalOrdersInfo.isNotEmpty) {
                  customersTotalOrdersInfo
                      .addAll(state.customersTotalOrdersInfo);
                } else {
                  isProductEnd = true;
                }
              }
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
              : onError && currentEvent == Event.orderDetails
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
                                      debugPrint(result.toIso8601String());
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
                                        if(result == beginDate){
                                          endDate = DateTime(beginDate.year, beginDate.month, beginDate.day, 24);
                                          debugPrint(endDate.toIso8601String());
                                        }else{
                                          endDate = result;
                                        }
                                        isLoading = true;
                                        offset = 0;
                                        currentEvent =
                                            Event.customerTotalOrdersInfo;
                                      });
                                      Map<String, dynamic> filters = {
                                        if (onDateSelected)
                                          'date': {
                                            'startDate':
                                                beginDate.toIso8601String(),
                                            'endDate':
                                                endDate.toIso8601String(),
                                          },
                                        if (orderStatus != 'all')
                                          'status': orderStatus,
                                        if (role != 'all') 'role': role,
                                      };
                                      if (kDebugMode) {
                                        print(filters.length);
                                      }
                                      bool filterActive = onDateSelected ||
                                          orderStatus != 'all' ||
                                          role != 'all';
                                      // ignore: use_build_context_synchronously
                                      getCustomersTotalOrdersInfo(
                                        context: context,
                                        token: jWTToken,
                                        data: {
                                          'filter': {
                                            'active': filterActive,
                                            if (filterActive)
                                              'filterInfo': {
                                                'filterLength': filters.length,
                                                'filters': filters,
                                              },
                                          },
                                          'offSet': offset,
                                        },
                                      );
                                    },
                            ),
                            OrderDropdown(
                              value: orderStatus,
                              onChanged: (String? value) {
                                setState(() {
                                  orderStatus = value ?? '';
                                  isLoading = true;
                                  offset = 0;
                                  currentEvent = Event.customerTotalOrdersInfo;
                                });
                                Map<String, dynamic> filters = {
                                  if (onDateSelected)
                                    'date': {
                                      'startDate': beginDate.toIso8601String(),
                                      'endDate': endDate.toIso8601String(),
                                    },
                                  if (orderStatus != 'all')
                                    'status': orderStatus,
                                  if (role != 'all') 'role': role,
                                };
                                if (kDebugMode) {
                                  print(filters.length);
                                }
                                bool filterActive = onDateSelected ||
                                    orderStatus != 'all' ||
                                    role != 'all';
                                // ignore: use_build_context_synchronously
                                getCustomersTotalOrdersInfo(
                                  context: context,
                                  token: jWTToken,
                                  data: {
                                    'filter': {
                                      'active': filterActive,
                                      if (filterActive)
                                        'filterInfo': {
                                          'filterLength': filters.length,
                                          'filters': filters,
                                        },
                                    },
                                  },
                                );
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
                                    currentEvent =
                                        Event.customerTotalOrdersInfo;
                                    offset = 0;
                                    orderStatus = 'all';
                                    onDateSelected = false;
                                  });
                                  // ignore: use_build_context_synchronously
                                  getCustomersTotalOrdersInfo(
                                    context: context,
                                    token: jWTToken,
                                    data: {
                                      'filter': {
                                        'active': false,
                                      },
                                    },
                                  );
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
                                    currentEvent =
                                        Event.customerTotalOrdersInfo;
                                  });
                                  Map<String, dynamic> filters = {
                                    if (onDateSelected)
                                      'date': {
                                        'startDate':
                                            beginDate.toIso8601String(),
                                        'endDate': endDate.toIso8601String(),
                                      },
                                    if (orderStatus != 'all')
                                      'status': orderStatus,
                                    if (role != 'all') 'role': role,
                                  };
                                  if (kDebugMode) {
                                    print(filters.length);
                                  }
                                  // ignore: use_build_context_synchronously
                                  getCustomersTotalOrdersInfo(
                                    context: context,
                                    token: jWTToken,
                                    data: {
                                      'filter': {
                                        'active': true,
                                        'filterInfo': {
                                          'filterLength': filters.length,
                                          'filters': filters,
                                        },
                                      },
                                    },
                                  );
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
                                    currentEvent =
                                        Event.customerTotalOrdersInfo;
                                    offset = 0;
                                  });
                                  Map<String, dynamic> filters = {
                                    if (onDateSelected)
                                      'date': {
                                        'startDate':
                                            beginDate.toIso8601String(),
                                        'endDate': endDate.toIso8601String(),
                                      },
                                    if (orderStatus != 'all')
                                      'status': orderStatus,
                                    if (role != 'all') 'role': role,
                                  };
                                  if (kDebugMode) {
                                    print(filters.length);
                                  }
                                  // ignore: use_build_context_synchronously
                                  getCustomersTotalOrdersInfo(
                                    context: context,
                                    token: jWTToken,
                                    data: {
                                      'filter': {
                                        'active': true,
                                        'filterInfo': {
                                          'filterLength': filters.length,
                                          'filters': filters,
                                        },
                                      },
                                    },
                                  );
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
                                    currentEvent =
                                        Event.customerTotalOrdersInfo;
                                    offset = 0;
                                  });
                                  Map<String, dynamic> filters = {
                                    if (onDateSelected)
                                      'date': {
                                        'startDate':
                                            beginDate.toIso8601String(),
                                        'endDate': endDate.toIso8601String(),
                                      },
                                    if (orderStatus != 'all')
                                      'status': orderStatus,
                                    if (role != 'all') 'role': role,
                                  };
                                  if (kDebugMode) {
                                    print(filters.length);
                                  }
                                  // ignore: use_build_context_synchronously
                                  getCustomersTotalOrdersInfo(
                                    context: context,
                                    token: jWTToken,
                                    data: {
                                      'filter': {
                                        'active': true,
                                        'filterInfo': {
                                          'filterLength': filters.length,
                                          'filters': filters,
                                        },
                                      },
                                    },
                                  );
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
                          child: isLoading &&
                                  currentEvent == Event.customerTotalOrdersInfo
                              ? const LoadingWidget()
                              : onError &&
                                      currentEvent ==
                                          Event.customerTotalOrdersInfo
                                  ? OnErrorWidget(
                                      onRefresh: () {
                                        setState(() {
                                          isLoading = true;
                                          onError = false;
                                        });
                                        Map<String, dynamic> filters = {
                                          if (onDateSelected)
                                            'date': {
                                              'startDate':
                                                  beginDate.toIso8601String(),
                                              'endDate':
                                                  endDate.toIso8601String(),
                                            },
                                          if (orderStatus != 'all')
                                            'status': orderStatus,
                                          if (role != 'all') 'role': role,
                                        };
                                        if (kDebugMode) {
                                          print(filters.length);
                                        }
                                        bool filterActive = onDateSelected ||
                                            orderStatus != 'all' ||
                                            role != 'all';
                                        // ignore: use_build_context_synchronously
                                        getCustomersTotalOrdersInfo(
                                          context: context,
                                          token: jWTToken,
                                          data: {
                                            'filter': {
                                              'active': filterActive,
                                              if (filterActive)
                                                'filterInfo': {
                                                  'filterLength':
                                                      filters.length,
                                                  'filters': filters,
                                                },
                                            },
                                          },
                                        );
                                      },
                                      message: errorMessage,
                                    )
                                  : ListView.builder(
                                      itemCount: isLoading &&
                                              currentEvent ==
                                                  Event
                                                      .updateCustomerTotalOrdersInfoList
                                          ? customersTotalOrdersInfo.length + 1
                                          : customersTotalOrdersInfo.length,
                                      controller: _scrollController,
                                      itemBuilder: (context, i) {
                                        if ((isLoading &&
                                                currentEvent ==
                                                    Event
                                                        .updateCustomerTotalOrdersInfoList) &&
                                            i ==
                                                customersTotalOrdersInfo
                                                    .length) {
                                          return const FetchingMoreLoadingIndicator();
                                        }
                                        return UserTotalOrderDetailsCard(
                                          info: customersTotalOrdersInfo[i],
                                        );
                                      }),
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
