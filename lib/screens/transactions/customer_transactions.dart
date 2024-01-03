import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_bloc/transactions/transactions_bloc.dart';
import 'package:viraeshop_bloc/transactions/transactions_event.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/generate_statement.dart';
import 'package:viraeshop_admin/configs/invoices/customer_goods_invoice.dart';
import 'package:viraeshop_admin/configs/invoices/print_customer_invoice.dart';
import 'package:viraeshop_admin/configs/invoices/share_customer_statement.dart';
import 'package:viraeshop_admin/reusable_widgets/transaction_functions/functions.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_admin/screens/transactions/user_transaction_screen.dart';
import 'package:viraeshop_api/utils/utils.dart';

import '../due/due_receipt.dart';
import '../reciept_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerTransactionScreen extends StatefulWidget {
  final String name;
  final String userID;
  final String queryType;
  final String adminId;
  const CustomerTransactionScreen(
      {required this.userID, required this.name,required this.adminId, Key? key, required this.queryType})
      : super(key: key);

  @override
  _CustomerTransactionScreenState createState() =>
      _CustomerTransactionScreenState();
}

class _CustomerTransactionScreenState extends State<CustomerTransactionScreen> {
  List data = [];
  List dataTemp = [];
  Tuple3<num, num, num> totals = const Tuple3<num, num, num>(0, 0, 0);
  Tuple3<num, num, num> totalsTemp = const Tuple3<num, num, num>(0, 0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  final jWTToken = Hive.box('adminInfo').get('token');
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
    transactionBloc.add(
      GetTransactionDetailsEvent(
        queryType: 'customerInvoice',
        userID: widget.userID,
        isFilter: false,
        token: jWTToken,
      ),
    );
    super.initState();
  }

  initSearch(String value) {
    if (value.length == 0) {
      setState(
        () {
          dataTemp = data;
        },
      );
    }
    final items = data.where((element) {
      final invoiceIdLower = element['invoiceNo'].toString();
      final valueLower = value.toLowerCase();
      return invoiceIdLower.contains(valueLower);
    }).toList();
    final List filtered = [];
    for (var element in items) {
      filtered.add(element);
    }
    setState(() {
      dataTemp = filtered;
    });
  }

  bool showPaid = false;
  bool showDue = false;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return BlocListener<TransactionsBloc, TransactionState>(
      listener: (context, state) {
        if (state is OnErrorTransactionState) {
          setState(() {
            isLoading = false;
          });
        } else if (state is RequestFinishedTransactionState) {
          final result = state.response.result;
          setState(() {
            isLoading = false;
            totals = Tuple3(result!['totalPaid'] ?? 0, result['totalDue'] ?? 0,
                result['totalAmount'] ?? 0);
            totalsTemp = totals;
            data = result['invoices'].toList();
            dataTemp = result['invoices'].toList();
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
              widget.name,
              style: kDrawerTextStyle2,
            ),
            leading: IconButton(
              onPressed: () {
                final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
                transactionBloc.add(
                  GetTransactionDetailsEvent(
                    queryType: widget.queryType,
                    userID: widget.adminId,
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
                    dataTemp = data;
                    totalsTemp = totals;
                  });
                },
                icon: const Icon(Icons.refresh),
                color: kBackgroundColor,
                iconSize: 20.0,
              ),
            ],
          ),
          backgroundColor: kBackgroundColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 0.76,
                child: SingleChildScrollView(
                  // padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Container(
                        height: 160.0,
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
                            const Text(
                              'Total Sales',
                              style: kDrawerTextStyle1,
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
                                    final transactionBloc =
                                    BlocProvider.of<TransactionsBloc>(
                                        context);
                                    transactionBloc.add(
                                      GetTransactionDetailsEvent(
                                        queryType: 'customerInvoice',
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
                                  },
                                ),
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
                                'Invoice No.',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            DataColumn(
                              onSort: (i, value) {
                                setState(() {
                                  showPaid = !showPaid;
                                  showDue = !showDue;
                                  if (showDue) {
                                    showDue = false;
                                  }
                                  if (showPaid) {
                                    dataTemp = data
                                        .where(
                                            (element) => element['paid'] != 0)
                                        .toList();
                                  } else {
                                    dataTemp = data;
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
                                  showPaid = !showPaid;
                                  if (showPaid) {
                                    showPaid = false;
                                  }
                                  if (showDue) {
                                    dataTemp = data
                                        .where((element) => element['due'] != 0)
                                        .toList();
                                  } else {
                                    dataTemp = data;
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
                          rows: List.generate(dataTemp.length, (index) {
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
                                      '${dataTemp[index]['invoiceNo']}',
                                      style: kCustomerCellStyle,
                                    ), onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return DueReceipt(
                                          data: dataTemp[index],
                                          title: 'Receipt',
                                          isOnlyShow: true,
                                        );
                                      },
                                    ),
                                  );
                                }),
                                DataCell(
                                  Text(
                                    dataTemp[index]['paid'].toString(),
                                    style: kTotalTextStyle,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dataTemp[index]['due'].toString(),
                                    style: kDueCellStyle,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    dataTemp[index]['price'].toString(),
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
              FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: 0.24,
                child: Container(
                  color: kBackgroundColor,
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
                                      value: totalsTemp.item1.toString(),
                                      title: 'Total Paid',
                                      color: kNewTextColor,
                                    ),
                              showPaid
                                  ? const SizedBox()
                                  : SpecialContainer(
                                      value: totalsTemp.item2.toString(),
                                      title: 'Total Due',
                                      color: kRedColor,
                                    ),
                              SpecialContainer(
                                value: totalsTemp.item3.toString(),
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
                                  shareCustomerStatement(
                                    name: widget.name,
                                    email: dataTemp[0]['customerInfo']
                                            ['email'] ??
                                        '',
                                    mobile: dataTemp[0]['customerInfo']
                                        ['mobile'],
                                    address: dataTemp[0]['customerInfo']
                                        ['address'],
                                    isInventory: true,
                                    items: data,
                                    begin: begin,
                                    end: end,
                                    totalAmount: totalsTemp.item3.toString(),
                                    totalDue: totalsTemp.item2.toString(),
                                    totalPay: totalsTemp.item1.toString(),
                                    isSave: true,
                                  );
                                  toast(
                                      context: context,
                                      title: 'Saved',
                                      color: kNewMainColor);
                                } catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              },
                            ),
                            buttons(
                              onTap: () {
                                shareCustomerStatement(
                                  name: widget.name,
                                  email: dataTemp[0]['customerInfo']['email'] ??
                                      '',
                                  mobile: dataTemp[0]['customerInfo']['mobile'],
                                  address: dataTemp[0]['customerInfo']
                                      ['address'],
                                  isInventory: true,
                                  items: data,
                                  begin: begin,
                                  end: end,
                                  totalAmount: totalsTemp.item3.toString(),
                                  totalDue: totalsTemp.item2.toString(),
                                  totalPay: totalsTemp.item1.toString(),
                                );
                              },
                              title: 'Share',
                            ),
                            buttons(
                                onTap: () {
                                  shareCustomerStatement(
                                      name: widget.name,
                                      email: dataTemp[0]['customerInfo']
                                              ['email'] ??
                                          '',
                                      mobile: dataTemp[0]['customerInfo']
                                          ['mobile'],
                                      address: dataTemp[0]['customerInfo']
                                          ['address'],
                                      isInventory: true,
                                      items: data,
                                      begin: begin,
                                      end: end,
                                      totalAmount: totalsTemp.item3.toString(),
                                      totalDue: totalsTemp.item2.toString(),
                                      totalPay: totalsTemp.item1.toString(),
                                      isPrint: true);
                                },
                                title: 'Print'),
                          ],
                        ),
                      ],
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
      lastDate: DateTime(2100),
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

Tuple3<num, num, num> tuple(List items, DateTime begin, DateTime end) {
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

List dateTupleList(List items, DateTime begin, DateTime end) {
  List filteredData = [];
  for (var element in items) {
    Timestamp timestamp = dateFromJson(element['createdAt']);
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      filteredData.add(element);
    }
  }
  return filteredData;
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
  dynamic onTap,
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

Widget searchBar(void Function(String)? onChanged) {
  return Row(
    children: [
      Container(
        width: 170.0,
        height: 50.0,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: kBackgroundColor,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Center(
          child: TextField(
            cursorColor: kBackgroundColor,
            textAlign: TextAlign.center,
            style: kDrawerTextStyle2,
            textAlignVertical: TextAlignVertical.center,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              hintText: 'Search',
              hintStyle: TextStyle(
                fontFamily: 'SourceSans',
                fontSize: 15.0,
                color: kBackgroundColor,
                letterSpacing: 1.3,
              ),
              border: InputBorder.none,
            ),
            onChanged: onChanged,
          ),
        ),
      ),
      // SizedBox(
      //   width: 20.0,
      // ),
      // roundedTextButton(
      //   borderColor: kBackgroundColor,
      //   textColor: kBackgroundColor,
      // ),
    ],
  );
}
