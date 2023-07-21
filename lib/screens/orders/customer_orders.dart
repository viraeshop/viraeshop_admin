import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop/customers/barrel.dart';
import 'package:viraeshop/orders/barrel.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/customerOrderInfoCard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_admin/screens/customers/tabWidgets.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_api/models/customers/customers.dart';
import 'package:viraeshop_api/models/orders/orders.dart';

import '../../components/styles/colors.dart';
import '../../components/styles/text_styles.dart';
import '../../reusable_widgets/loading_widget.dart';
import '../../reusable_widgets/on_error_widget.dart';
import '../../reusable_widgets/orders/order_chips.dart';
import 'orderRoutineReport.dart';

enum Events {
  getCustomer,
  getOrders,
}

class CustomerOrders extends StatefulWidget {
  const CustomerOrders({Key? key, required this.title, required this.info})
      : super(key: key);
  final String title;
  final Map<String, dynamic> info;

  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  String status = 'all';
  String errorMessage = '';
  Events currentEvent = Events.getCustomer;
  final jWTToken = Hive.box('adminInfo').get('token');
  Map<String, dynamic> customerInfo = {};
  List<Orders> orderList = [];
  List<String> allStatus = [
    'All',
    'Pending',
    'Confirmed',
    'Canceled',
    'Failed',
    'Success'
  ];
  bool onError = false;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    final customerBloc = BlocProvider.of<CustomersBloc>(context);
    customerBloc.add(GetCustomerEvent(
        customerId: widget.info['customerId'], token: jWTToken));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<CustomersBloc, CustomerState>(
              listener: (context, state) {
            if (state is FetchedCustomerState) {
              setState(() {
                customerInfo = state.customer.result.toJson();
              });
            } else if (state is OnErrorCustomerState) {
              setState(() {
                onError = true;
                isLoading = false;
              });
            }
          }),
          // BlocListener<OrdersBloc, OrderState>(listener: (context, state) {
          //   if (state is FetchedOrdersState) {
          //     setState(() {
          //       orderList = state.orderList;
          //     });
          //   }
          // }),
        ],
        child: customerInfo.isEmpty
            ? const LoadingWidget()
            : onError && currentEvent == Events.getCustomer
                ? OnErrorWidget(message: errorMessage)
                : Container(
                    padding: const EdgeInsets.all(10.0),
                    height: screenSize.height,
                    width: screenSize.width,
                    child: Column(
                      children: [
                        CustomerOrderInfoCard(
                          customerInfo: customerInfo,
                          orderInfo: widget.info,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                              allStatus.sublist(0, 3).length, (index) {
                            return OrderChips(
                              width: 140.0,
                              title:
                                  '${allStatus[index]} ${valueReturner(allStatus[index], widget.info)}',
                              isSelected: status == allStatus[index],
                              onTap: () {
                                setState(() {
                                  status = allStatus[index];
                                });
                                if (status == 'All') {
                                  getOrders(
                                    data: {
                                      'filterType': 'default',
                                      'filterData': {
                                        'customerId':
                                            customerInfo['customerId'],
                                      }
                                    },
                                    context: context,
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateOnStatusFilter(false, status.toLowerCase());
                                } else {
                                  getOrders(
                                    data: {
                                      'filterType': 'orderStatus',
                                      'filterData': {
                                        'customerId':
                                            customerInfo['customerId'],
                                        'orderStatus':
                                            allStatus[index].toLowerCase(),
                                      }
                                    },
                                    context: context,
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateOnStatusFilter(true, status.toLowerCase());
                                }
                              },
                            );
                          }),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(allStatus.sublist(3).length,
                              (index) {
                            return OrderChips(
                              width: 140.0,
                              title:
                                  '${allStatus[index]} ${valueReturner(allStatus[index], widget.info)}',
                              isSelected: status == allStatus[index],
                              onTap: () {
                                setState(() {
                                  status = allStatus[index];
                                });
                                getOrders(
                                  data: {
                                    'filterType': 'orderStatus',
                                    'filterData': {
                                      'customerId': customerInfo['customerId'],
                                      'orderStatus':
                                          allStatus[index].toLowerCase(),
                                    }
                                  },
                                  context: context,
                                );
                                Provider.of<OrderProvider>(context,
                                        listen: false)
                                    .updateOnStatusFilter(true, status.toLowerCase());
                              },
                            );
                          }),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        LimitedBox(
                          maxHeight: screenSize.height * 0.5,
                          child: OrdersTab(userId: customerInfo['customerId']),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }
}

dynamic valueReturner(String value, Map<String, dynamic> info) {
  switch (value) {
    case 'All':
      return info['total'];
    case 'Pending':
      return info['pendings'];
    case 'Confirmed':
      return info['confirmed'];
    case 'Canceled':
      return info['canceled'];
    case 'Failed':
      return info['failed'];
    case 'Success':
      return info['success'];
  }
}
