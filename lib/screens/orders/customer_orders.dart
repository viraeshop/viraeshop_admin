import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_bloc/customers/barrel.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
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
import '../../reusable_widgets/orders/functions.dart';
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
  bool isLoading = true;

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
      body: BlocListener<CustomersBloc, CustomerState>(
        listener: (context, state) {
          if (state is FetchedCustomerState) {
            setState(() {
              isLoading = false;
              customerInfo = state.customer.result.toJson();
            });
          } else if (state is OnErrorCustomerState) {
            setState(() {
              onError = true;
              isLoading = false;
              errorMessage = state.message;
            });
          }
        },
        child: isLoading
            ? const LoadingWidget()
            : onError && currentEvent == Events.getCustomer
                ? Center(
                    child: OnErrorWidget(
                      onRefresh: () {
                        setState(() {
                          isLoading = true;
                          onError = false;
                        });
                        final customerBloc =
                            BlocProvider.of<CustomersBloc>(context);
                        customerBloc.add(GetCustomerEvent(
                            customerId: widget.info['customerId'],
                            token: jWTToken));
                      },
                      message: errorMessage,
                    ),
                  )
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
                                  Map<String, dynamic> filterInfo = {
                                    'filterType': 'default',
                                    'filterData': {
                                      'customerId':
                                      customerInfo['customerId'],
                                    }
                                  };
                                  getOrders(
                                    data: filterInfo,
                                    context: context,
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateFilterInfo(filterInfo);
                                } else {
                                  Map<String, dynamic> filterInfo = {
                                    'filterType': 'orderStatus',
                                    'filterData': {
                                      'customerId':
                                      customerInfo['customerId'],
                                      'status':
                                      allStatus[index].toLowerCase(),
                                    }
                                  };
                                  getOrders(
                                    data: filterInfo,
                                    context: context,
                                  );
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateFilterInfo(filterInfo);
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
                                  '${allStatus.sublist(3)[index]} ${valueReturner(allStatus.sublist(3)[index], widget.info)}',
                              isSelected: status == allStatus.sublist(3)[index],
                              onTap: () {
                                setState(() {
                                  status = allStatus.sublist(3)[index];
                                });
                                Map<String, dynamic> filterInfo = {
                                  'filterType': 'orderStatus',
                                  'filterData': {
                                    'customerId': customerInfo['customerId'],
                                    'status': allStatus
                                        .sublist(3)[index]
                                        .toLowerCase(),
                                  }
                                };
                                getOrders(
                                  data: filterInfo,
                                  context: context,
                                );
                                Provider.of<OrderProvider>(context,
                                        listen: false)
                                    .updateFilterInfo(filterInfo);
                              },
                            );
                          }),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        LimitedBox(
                          maxHeight: screenSize.height * 0.46,
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
