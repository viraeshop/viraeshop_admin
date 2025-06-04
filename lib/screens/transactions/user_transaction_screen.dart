import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_bloc/transactions/transactions_bloc.dart';
import 'package:viraeshop_bloc/transactions/transactions_event.dart';
import 'package:viraeshop_bloc/transactions/transactions_state.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/configs/generate_statement.dart';
import 'package:viraeshop_admin/configs/pos_printer.dart';
import 'package:viraeshop_admin/configs/print_statement.dart';
import 'package:viraeshop_admin/configs/share_statement.dart';
import 'package:viraeshop_admin/reusable_widgets/transaction_functions/functions.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_admin/screens/transactions/non_inventory_transactions.dart';
import 'package:viraeshop_api/utils/utils.dart';

import 'customer_transactions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserTransactionScreen extends StatefulWidget {
  final String name;
  final String queryType;
  final String userID;
  final bool isFromEmployee;
  const UserTransactionScreen(
      {Key? key,
      this.isFromEmployee = true,
      required this.name,
      required this.queryType,
      required this.userID})
      : super(key: key);

  @override
  _UserTransactionScreenState createState() => _UserTransactionScreenState();
}

class _UserTransactionScreenState extends State<UserTransactionScreen> {
  List transactionData = [];
  List backupTransactionData = [];
  Tuple3<num, num, num> totalBalance = const Tuple3<num, num, num>(0, 0, 0);
  Tuple3<num, num, num> totalBalanceTemp = const Tuple3<num, num, num>(0, 0, 0);
  static DateTime begin = DateTime.now();
  DateTime end = begin;
  final jWTToken = Hive.box('adminInfo').get('token');
  bool isLoading = true;
  // Set customers = {};
  // Set customerSet = {};
  @override
  void initState() {
    final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
    transactionBloc.add(
      GetTransactionDetailsEvent(
        queryType: widget.queryType,
        userID: widget.userID,
        isFilter: false,
        token: jWTToken,
      ),
    );
    super.initState();
  }

  initSearch(String value) {
    if (value.isEmpty) {
      setState(
        () {
          transactionData = backupTransactionData.toList();
        },
      );
    }
    List items = backupTransactionData.where((element) {
      final nameLower = element['name'].toLowerCase();
      final businessNameLower = element['businessName'].toLowerCase();
      final valueLower = value.toLowerCase();
      return nameLower.contains(valueLower) ||
          businessNameLower.contains(valueLower);
    }).toList();
    setState(() {
      transactionData = items.toList();
    });
  }

  /// this is the list of customer id's used as keys of map
  bool showPaid = false;
  bool showDue = false;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return BlocListener<TransactionsBloc, TransactionState>(
      listenWhen: (prev, current) {
        if (prev is RequestFinishedTransactionState &&
            current is OnErrorTransactionState) {
          return false;
        } else {
          return true;
        }
      },
      listener: (context, state) {
        if (state is OnErrorTransactionState) {
          setState(() {
            isLoading = false;
          });
        } else if (state is RequestFinishedTransactionState) {
          final Map<String, dynamic>? data = state.response.result;
          if (kDebugMode) {
            print(data);
          }
          setState(() {
            isLoading = false;
            if (data!.isNotEmpty) {
              totalBalance = Tuple3(data['totalPaid'] ?? 0,
                  data['totalDue'] ?? 0, data['totalAmount'] ?? 0);
              totalBalanceTemp = totalBalance;
              transactionData = data['invoices'].toList() ?? [];
              backupTransactionData = data['invoices'].toList() ?? [];
            }
          });
        } else if (state is LoadingTransactionState) {
          setState(() {
            isLoading = true;
          });
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 40.0,
            backgroundColor: kSubMainColor,
            elevation: 0.0,
            shape: const Border(
              bottom: BorderSide(
                color: kSubMainColor,
              ),
            ),
            title: Text(
              '${widget.name}\'s Total Sales',
              style: kDrawerTextStyle1,
            ),
            leading: IconButton(
              onPressed: () {
                final transactionBloc =
                    BlocProvider.of<TransactionsBloc>(context);
                transactionBloc.add(
                  GetTransactionDetailsEvent(
                    queryType:
                        widget.isFromEmployee ? 'employees' : 'customers',
                    isFilter: false,
                    token: jWTToken,
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(
                FontAwesomeIcons.chevronLeft,
              ),
              color: kBackgroundColor,
              iconSize: 20.0,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    begin = DateTime.now();
                    end = DateTime.now();
                  });
                  final transactionBloc =
                      BlocProvider.of<TransactionsBloc>(context);
                  transactionBloc.add(
                    GetTransactionDetailsEvent(
                      queryType: widget.queryType,
                      userID: widget.userID,
                      isFilter: false,
                      token: jWTToken,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                color: kBackgroundColor,
                iconSize: 30.0,
              ),
            ],
          ),
          backgroundColor: kBackgroundColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 0.7,
                child: SingleChildScrollView(
                  // padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Container(
                        height: 170.0,
                        width: screenSize.width,
                        padding: const EdgeInsets.all(10.0),
                        decoration: const BoxDecoration(
                          color: kSubMainColor,
                          border: Border(
                              // bottom: BorderSide(color: kBackgroundColor,),
                              ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MyOutlinedButton(
                                  title: 'All',
                                  onTap: () {
                                    setState(() {
                                      isLoading = true;
                                      begin = DateTime.now();
                                      end = DateTime.now();
                                    });
                                    final transactionBloc =
                                        BlocProvider.of<TransactionsBloc>(
                                            context);
                                    transactionBloc.add(
                                      GetTransactionDetailsEvent(
                                        queryType: widget.queryType,
                                        userID: widget.userID,
                                        isFilter: false,
                                        token: jWTToken,
                                      ),
                                    );
                                  },
                                ),
                                MyOutlinedButton(
                                  title: 'Sales',
                                  onTap: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    bool onDateFilter = !begin.isAtSameMomentAs(end);
                                    final transactionBloc =
                                    BlocProvider.of<TransactionsBloc>(
                                        context);
                                    transactionBloc.add(
                                      GetTransactionDetailsEvent(
                                        queryType: widget.queryType,
                                        userID: widget.userID,
                                        isFilter: onDateFilter,
                                        token: jWTToken,
                                        begin: onDateFilter ? dateToJson(
                                          Timestamp.fromDate(begin),
                                        ) : '',
                                        end: onDateFilter ? dateToJson(
                                          Timestamp.fromDate(end),
                                        ) : '',
                                        channel: 'in_store',
                                      ),
                                    );
                                  },
                                ),
                                MyOutlinedButton(
                                  title: 'Orders',
                                  onTap: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    bool onDateFilter = !begin.isAtSameMomentAs(end);
                                    final transactionBloc =
                                    BlocProvider.of<TransactionsBloc>(
                                        context);
                                    transactionBloc.add(
                                      GetTransactionDetailsEvent(
                                        queryType: widget.queryType,
                                        userID: widget.userID,
                                        isFilter: onDateFilter,
                                        token: jWTToken,
                                        begin: onDateFilter ? dateToJson(
                                          Timestamp.fromDate(begin),
                                        ) : '',
                                        end: onDateFilter ? dateToJson(
                                          Timestamp.fromDate(end),
                                        ) : '',
                                        channel: 'mobile_app',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                dateWidget(
                                  borderColor: kBackgroundColor,
                                  color: kBackgroundColor,
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
                                    borderColor: kBackgroundColor,
                                    color: kBackgroundColor,
                                    onTap: () {
                                      buildMaterialDatePicker(context, false);
                                    },
                                    title: end.isAtSameMomentAs(DateTime.now())
                                        ? 'To this date..'
                                        : end.toString().split(' ')[0]),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                roundedTextButton(
                                    borderColor: kBackgroundColor,
                                    textColor: kBackgroundColor,
                                    onTap: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      final beginFormat = DateTime(
                                          begin.year, begin.month, begin.day);
                                      final endFormat = DateTime(
                                          end.year, end.month, end.day);
                                      if (beginFormat == endFormat) {
                                        int day = begin.day;
                                        int month = begin.month;
                                        int year = begin.year;
                                        if (lastDayOfMonth(
                                                begin.day, begin.month) ==
                                            LastDay.lastDay) {
                                          end =
                                              DateTime(begin.year, month++, 1);
                                        } else if (lastDayOfMonth(
                                                begin.day, begin.month) ==
                                            LastDay.endingYear) {
                                          end = DateTime(year++, 1, 1);
                                        } else {
                                          begin = DateTime(
                                              begin.year, begin.month, day++);
                                        }
                                      }
                                      final transactionBloc =
                                          BlocProvider.of<TransactionsBloc>(
                                              context);
                                      transactionBloc.add(
                                        GetTransactionDetailsEvent(
                                          queryType: widget.queryType,
                                          userID: widget.userID,
                                          isFilter: true,
                                          token: jWTToken,
                                          begin: dateToJson(
                                            Timestamp.fromDate(begin),
                                          ),
                                          end: dateToJson(
                                            Timestamp.fromDate(end),
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            searchBar((value) {
                              initSearch(value);
                            }),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                            (states) {
                              return kStrokeColor;
                            },
                          ),
                          columns: [
                            const DataColumn(
                              label: Text(
                                'SL',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Customer name/ID',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            DataColumn(
                              onSort: (i, value) {
                                setState(() {
                                  showPaid = !showPaid;
                                  if (showDue) {
                                    showDue = false;
                                  }
                                  if (showPaid) {
                                    transactionData = backupTransactionData
                                        .where((element) =>
                                            element['totalPaid'] != 0)
                                        .toList();
                                  } else {
                                    transactionData =
                                        backupTransactionData.toList();
                                  }
                                });
                              },
                              label: const Text(
                                'Paid',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            DataColumn(
                              onSort: (i, value) {
                                setState(() {
                                  showDue = !showDue;
                                  if (showPaid) {
                                    showPaid = false;
                                  }
                                  if (showDue) {
                                    transactionData = backupTransactionData
                                        .where((element) =>
                                            element['totalDue'] != 0)
                                        .toList();
                                  } else {
                                    transactionData =
                                        backupTransactionData.toList();
                                  }
                                });
                              },
                              label: const Text(
                                'Due',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Amount',
                                style: kTotalSalesStyle,
                              ),
                            ),
                          ],
                          rows: List.generate(transactionData.length, (index) {
                            int counter = index + 1;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    counter.toString(),
                                    style: kTableCellStyle,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transactionData[index]['businessName'] !=
                                                null &&
                                            transactionData[index]
                                                    ['businessName'].isNotEmpty
                                        ? transactionData[index]
                                                ['businessName'] ??
                                            ''
                                        : transactionData[index]['name'] ?? '',
                                    style: kCustomerCellStyle,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CustomerTransactionScreen(
                                            userID: transactionData[index]
                                                    ['customerId'] ??
                                                '',
                                            name: transactionData[index]
                                                            ['businessName'] !=
                                                        null &&
                                                    transactionData[index]
                                                            ['businessName'] !=
                                                        ''
                                                ? transactionData[index]
                                                        ['businessName'] ??
                                                    ''
                                                : transactionData[index]
                                                        ['name'] ??
                                                    '',
                                            queryType: widget.queryType,
                                            adminId: widget.userID,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                DataCell(
                                  Text(
                                    transactionData[index]['totalPaid']
                                            ?.toString() ??
                                        '0',
                                    style: kTotalTextStyle,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transactionData[index]['totalDue']
                                            ?.toString() ??
                                        '0',
                                    style: kDueCellStyle,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    transactionData[index]['totalAmount']
                                            ?.toString() ??
                                        '0',
                                    style: kTotalTextStyle,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.31,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          LimitedBox(
                            maxHeight: 140,
                            child: GridView(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10.0,
                                crossAxisSpacing: 10.0,
                                childAspectRatio: 1,
                              ),
                              children: [
                                showDue
                                    ? const SizedBox()
                                    : SpecialContainer(
                                        value: totalBalanceTemp.item1.toString(),
                                        title: 'Total Paid',
                                        color: kNewTextColor,
                                      ),
                                showPaid
                                    ? const SizedBox()
                                    : SpecialContainer(
                                        value: totalBalanceTemp.item2.toString(),
                                        title: 'Total Due',
                                        color: kRedColor,
                                      ),
                                SpecialContainer(
                                  value: totalBalanceTemp.item3.toString(),
                                  title: 'Amount',
                                  color: kBlueColor,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buttons(
                                title: 'Save PDF',
                                onTap: () {
                                  try {
                                    shareStatement(
                                      items: transactionData,
                                      begin: begin,
                                      end: end,
                                      name: widget.name ?? '',
                                      totalAmount:
                                          totalBalanceTemp.item3.toString(),
                                      totalDue: totalBalanceTemp.item2.toString(),
                                      totalPay: totalBalanceTemp.item1.toString(),
                                      isSave: true,
                                    );
                                    toast(
                                      context: context,
                                      title: 'saved',
                                      color: kNewMainColor,
                                    );
                                  } catch (e) {
                                    if (kDebugMode) {
                                      print(e);
                                    }
                                  }
                                },
                              ),
                              buttons(
                                onTap: () {
                                  shareStatement(
                                    items: transactionData,
                                    begin: begin,
                                    end: end,
                                    name: widget.name ?? '',
                                    totalAmount:
                                        totalBalanceTemp.item3.toString(),
                                    totalDue: totalBalanceTemp.item2.toString(),
                                    totalPay: totalBalanceTemp.item1.toString(),
                                  );
                                },
                                title: 'Share',
                              ),
                              buttons(
                                  onTap: () {
                                    shareStatement(
                                      items: transactionData,
                                      begin: begin,
                                      end: end,
                                      name: widget.name ?? '',
                                      totalAmount:
                                          totalBalanceTemp.item3.toString(),
                                      totalDue: totalBalanceTemp.item2.toString(),
                                      totalPay: totalBalanceTemp.item1.toString(),
                                      isPrint: true,
                                    );
                                  },
                                  title: 'Print'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
      lastDate: DateTime(2300),
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

class MyOutlinedButton extends StatelessWidget {
  const MyOutlinedButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.0,
        height: 40.0,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: kBackgroundColor,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: Text(
            title,
            style: kDrawerTextStyle2.copyWith(
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }
}

Tuple3<num, num, num> tuple(List items) {
  num sale = 0, due = 0, paid = 0;
  for (var element in items) {
    paid += element['paid'];
    if (element['paid'] == 0) {
      paid += element['advance'];
    }
    sale += element['price'];
    due += element['due'];
  }
  Tuple3<num, num, num> data = Tuple3<num, num, num>(paid, due, sale);
  return data;
}

/// This function will check the date range and return the sum of sales, due,
/// and paid for each and every customer
Tuple3<num, num, num> dateTuple(List items, DateTime begin, DateTime end) {
  num sale = 0, due = 0, paid = 0;
  for (var element in items) {
    Timestamp timestamp = dateFromJson(element['createdAt']);
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      paid += element['paid'];
      if (element['paid'] == 0 && element['advance'] != 0) {
        paid += element['advance'];
      }
      sale += element['price'];
      due += element['due'];
    }
  }
  Tuple3<num, num, num> data = Tuple3<num, num, num>(paid, due, sale);
  return data;
}

// ignore: avoid_init_to_null
Widget buttons({String title = '', var width = null, var onTap = null}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: width,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: kBlackColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'SourceSans',
            fontSize: 12.0,
            color: kBlackColor,
            letterSpacing: 1.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget infoCard(String title, Color color) {
  return Container(
    width: double.infinity,
    height: 30.0,
    // margin: EdgeInsets.all(10.0),
    padding: const EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4.0),
    ),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SourceSans',
            fontSize: 15.0,
            color: kBackgroundColor,
            letterSpacing: 1.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget dateWidget({
  required String title,
  Color borderColor = kMainColor,
  // ignore: avoid_init_to_null
  color = kNewTextColor,
  dynamic onTap = null,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      // height: 30.0,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SourceSans',
                fontSize: 12.0,
                color: color,
                letterSpacing: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.calendar_view_month,
              color: color,
            ),
          ],
        ),
      ),
    ),
  );
}
