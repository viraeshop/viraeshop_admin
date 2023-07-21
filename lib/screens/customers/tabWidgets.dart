import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop/orders/barrel.dart';
import 'package:viraeshop/transactions/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/on_error_widget.dart';
import 'package:viraeshop_admin/screens/orders/orderRoutineReport.dart';
import 'package:viraeshop_admin/screens/orders/order_info_view.dart';
import 'package:viraeshop_admin/screens/orders/order_products.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_admin/screens/reciept_screen.dart';
import 'package:viraeshop_api/models/items/items.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_api/utils/utils.dart';

import '../../configs/boxes.dart';
import '../../reusable_widgets/loading_widget.dart';
import '../transactions/customer_transactions.dart';
import '../due/due_receipt.dart';
import '../orders/order_tranz_card.dart';
import '../transactions/transaction_details.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesTab extends StatefulWidget {
  final String userId;
  final bool isAdmin;
  const SalesTab({required this.userId, this.isAdmin = false, Key? key})
      : super(key: key);

  @override
  _SalesTabState createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  List transactions = [];
  List transactionBackup = [];
  List invoiceNo = [];
  bool isLoading = true, isError = false;
  num totalPaid = 0;
  num totalDue = 0;
  num totalAmount = 0;
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  bool isPaid = false;
  bool isDue = false;
  String message = '';
  bool onError = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    if (kDebugMode) {
      print(widget.userId);
    }
    String filterField = widget.isAdmin == true ? 'employee' : 'customer';
    final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
    transactionBloc.add(GetTransactionsEvent(
        token: jWTToken, queryType: filterField, id: widget.userId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(loaded);
    // print(invoiceNo);
    return BlocListener<TransactionsBloc, TransactionState>(
      listener: (context, state) {
        if (state is OnErrorTransactionState) {
          setState(() {
            isLoading = false;
            onError = true;
            message = state.message;
          });
        } else if (state is FetchedTransactionsState) {
          //if (onFilter == false) {
          if (kDebugMode) {
            print('Yeah i got here');
          }
          setState(() {
            isLoading = false;
            transactions.clear();
            transactionBackup.clear();
            final data = state.transactionList;
            List transactionsListTemp = [];
            for (var element in data) {
              transactionsListTemp.add(element.toJson());
              totalPaid += element.paid;
              if (element.paid == 0 && element.advance != 0) {
                totalPaid += element.advance;
              }
              totalDue += element.due;
              totalAmount += element.price;
            }
            transactions = transactionsListTemp.toList();
            transactionBackup = transactionsListTemp.toList();
          });
          // }
        }
      },
      child: isLoading
          ? const Center(
              child: SizedBox(
                height: 40.0,
                width: 40.0,
                child: CircularProgressIndicator(
                  color: kMainColor,
                ),
              ),
            )
          : onError
              ? Center(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: kProductNameStyle,
                  ),
                )
              : Container(
                  child: transactionBackup.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            FractionallySizedBox(
                              alignment: Alignment.topCenter,
                              heightFactor: 0.88,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 70.0),
                                child: Column(
                                  children: List.generate(
                                    transactions.length,
                                    (int i) {
                                      List items = transactions[i]['items'];
                                      String description = '';
                                      for (var element in items) {
                                        description +=
                                            '${element['quantity']} X ${element['productName']}, ';
                                      }
                                      Timestamp timestamp = dateFromJson(
                                          transactions[i]['createdAt']);
                                      String date = DateFormat.yMMMd()
                                          .format(timestamp.toDate());
                                      String customerName = transactions[i]
                                                  ['role'] ==
                                              'general'
                                          ? transactions[i]['customerInfo']
                                              ['name']
                                          : transactions[i]['customerInfo']
                                                  ['businessName'] +
                                              '(${transactions[i]['customerInfo']['name']})';
                                      return OrderTranzCard(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return DueReceipt(
                                              title: 'Receipt',
                                              data: transactions[i],
                                              isOnlyShow: true,
                                              isNeedRefresh: true,
                                              userId: widget.userId,
                                            );
                                          }));
                                        },
                                        date: date,
                                        price:
                                            transactions[i]['price'].toString(),
                                        employeeName: transactions[i]
                                            ['adminInfo']['name'],
                                        customerName: customerName,
                                        desc: description,
                                        id: transactions[i]['invoiceNo']
                                            .toString(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 70.0,
                                padding: const EdgeInsets.all(10.0),
                                decoration: const BoxDecoration(
                                  color: kBackgroundColor,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    dateWidget(
                                      borderColor: kSubMainColor,
                                      color: kSubMainColor,
                                      title: begin.toString().split(' ')[0],
                                      onTap: () {
                                        buildMaterialDatePicker(context, true);
                                      },
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: kSubMainColor,
                                      size: 20.0,
                                    ),
                                    dateWidget(
                                        borderColor: kSubMainColor,
                                        color: kSubMainColor,
                                        onTap: () {
                                          buildMaterialDatePicker(
                                              context, false);
                                        },
                                        title:
                                            end.isAtSameMomentAs(DateTime.now())
                                                ? 'To this date..'
                                                : end.toString().split(' ')[0]),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    roundedTextButton(
                                        borderColor: kSubMainColor,
                                        textColor: kSubMainColor,
                                        onTap: () {
                                          setState(() {
                                            transactions = dateFilter(
                                                transactionBackup, begin, end);
                                            totalPaid = 0;
                                            totalDue = 0;
                                            totalAmount = 0;
                                            for (var element in transactions) {
                                              totalPaid += element['paid'];
                                              if (element['paid'] == 0 &&
                                                  element['advance'] != 0) {
                                                totalPaid += element['advance'];
                                              }
                                              totalDue += element['due'];
                                              totalAmount += element['price'];
                                            }
                                          });
                                        }),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          transactions = transactionBackup;
                                          totalPaid = 0;
                                          totalDue = 0;
                                          totalAmount = 0;
                                          for (var element in transactions) {
                                            totalPaid += element['paid'];
                                            if (element['paid'] == 0 &&
                                                element['advance'] != 0) {
                                              totalPaid += element['advance'];
                                            }
                                            totalDue += element['due'];
                                            totalAmount += element['price'];
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.refresh),
                                      color: kSubMainColor,
                                      iconSize: 30.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              heightFactor: 0.12,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                color: kSubMainColor,
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    isDue
                                        ? const SizedBox()
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isPaid = !isPaid;
                                                if (isPaid) {
                                                  transactions =
                                                      transactionBackup
                                                          .where((element) =>
                                                              element['paid'] !=
                                                              0)
                                                          .toList();
                                                } else {
                                                  transactions =
                                                      transactionBackup;
                                                }
                                              });
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Total Paid:',
                                                  style: TextStyle(
                                                    color: kBackgroundColor,
                                                    fontSize: 15.0,
                                                    letterSpacing: 1.3,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  ' ${totalPaid.toString()}$bdtSign',
                                                  style: const TextStyle(
                                                    color: kMainColor,
                                                    fontSize: 15.0,
                                                    letterSpacing: 1.3,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    isPaid
                                        ? const SizedBox()
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isDue = !isDue;
                                                if (isDue) {
                                                  transactions =
                                                      transactionBackup
                                                          .where((element) =>
                                                              element['due'] !=
                                                              0)
                                                          .toList();
                                                } else {
                                                  transactions =
                                                      transactionBackup;
                                                }
                                              });
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Total Due:',
                                                  style: TextStyle(
                                                    color: kBackgroundColor,
                                                    fontSize: 15.0,
                                                    letterSpacing: 1.3,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  ' ${totalDue.toString()}$bdtSign',
                                                  style: const TextStyle(
                                                    color: kRedColor,
                                                    fontSize: 15.0,
                                                    letterSpacing: 1.3,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Total Amount:',
                                          style: TextStyle(
                                            color: kBackgroundColor,
                                            fontSize: 15.0,
                                            letterSpacing: 1.3,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          ' ${totalAmount.toString()}$bdtSign',
                                          style: const TextStyle(
                                            color: kNewMainColor,
                                            fontSize: 15.0,
                                            letterSpacing: 1.3,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: kProductNameStyle,
                          ),
                        ),
                ),
    );
  }

  buildMaterialDatePicker(BuildContext context, bool isBegin) async {
    DateTime date = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      fieldHintText: 'Month/Date/Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != begin) {
      if (isBegin) {
        setState(() {
          begin = picked;
        });
      } else {
        setState(() {
          end = picked;
        });
      }
    }
  }
}

class OrdersTab extends StatefulWidget {
  final String userId;
  OrdersTab({required this.userId});

  @override
  _OrdersTabState createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<Orders> orders = [];
  bool isLoading = false, onError = false, onUpdate = false;
  String errorMessage = '';
  final jWTToken = Hive.box('adminInfo').get('token');
  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  @override
  void initState() {
    getOrders(
      data: {
        'filterType': 'default',
        'filterData': {
          'customerId': widget.userId,
        }
      },
      context: context,
    );
    _scrollController.addListener(() {
      bool onStatusFilter = Provider.of<OrderProvider>(context, listen: false).onStatusFilter;
      String currentStatus =  Provider.of<OrderProvider>(context, listen: false).currentOrderStatus;
      setState(() {
        isLoading = true;
        offset += 20;
        onUpdate = true;
      });
      getOrders(
        data: {
          'offSet': offset,
          'filterType': onStatusFilter ? 'orderStatus' : 'default',
          'filterData': {
            'customerId': widget.userId,
            if(onStatusFilter)'orderStatus': currentStatus,
          }
        },
        context: context,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersBloc, OrderState>(
        buildWhen: (prevState, currentState) {
      if (currentState is FetchedOrdersState) {
        return true;
      } else if (currentState is OnErrorOrderState && !onUpdate) {
        return true;
      } else if (currentState is LoadingOrderState && !onUpdate) {
        return true;
      } else {
        return false;
      }
    }, listenWhen: (prevState, state) {
      if (state is OnErrorOrderState && onUpdate) {
        return true;
      } else {
        return false;
      }
    }, listener: (context, state) {
      if (state is OnErrorOrderState) {
        setState(() {
          onError = true;
          isLoading = false;
          errorMessage = state.message;
        });
      }
      // } else if (state is FetchedOrdersState) {
      //   setState(() {
      //     isLoading = false;
      //     orders.addAll(state.orderList);
      //   });
      // }
    }, builder: (context, state) {
      if (state is FetchedOrdersState) {
        if(orders.isNotEmpty){
          orders.addAll(state.orderList);
          isLoading = false;
          onUpdate = false;
        }else{
          orders = state.orderList;
        }
        return ListView.builder(
          itemCount: onUpdate ? orders.length + 1 : orders.length,
          shrinkWrap: true,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int i) {
            List<Items> items = orders[i].items;
            String description = '';
            for (var element in items) {
              description += '${element.quantity}x ${element.productName} ';
            }
            Timestamp timestamp = dateFromJson(orders[i].createdAt);
            String date = DateFormat.yMMMd().format(timestamp.toDate());
            if(onUpdate && i == orders.length){
              return const FetchingMoreLoadingIndicator();
            }
            return OrderTranzCard(
              onTap: () {
                OrderStages currentStage =
                    Provider.of<OrderProvider>(context, listen: false).currentStage;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OrderProducts(
                        customerInfo: orders[i].customer.toJson(),
                        orderInfo: orders[i].toJson(),
                        onGetAdmins: currentStage != OrderStages.order,
                      );
                    },
                  ),
                );
              },
              date: date,
              price: orders[i].price.toString(),
              employeeName: 'Riyadh',
              customerName: orders[i].customer.name,
              desc: description,
              id: orders[i].orderId,
            );
          },
        );
      } else if (state is OnErrorOrderState) {
        return OnErrorWidget(message: state.message);
      }
      return const LoadingWidget();
    });
  }
}

class FetchingMoreLoadingIndicator extends StatelessWidget {
  const FetchingMoreLoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          LoadingWidget(),
          SizedBox(
            width: 5.0,
          ),
          Text('Fetching more....', style: kSansTextStyleSmallBlack,),
        ],
      ),
    );
  }
}

void getOrders(
    {required Map<String, dynamic> data, required BuildContext context}) {
  final jWTToken = Hive.box('adminInfo').get('token');
  final orderBloc = BlocProvider.of<OrdersBloc>(context);
  orderBloc.add(
    GetOrdersEvent(
      token: jWTToken,
      data: data,
    ),
  );
}
