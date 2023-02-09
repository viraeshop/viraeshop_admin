import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop/transactions/transactions_bloc.dart';
import 'package:viraeshop/transactions/transactions_event.dart';
import 'package:viraeshop/transactions/transactions_state.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/invoices/share_customer_statement.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_api/utils/utils.dart';

import '../customers/preferences.dart';
import 'customer_transactions.dart';
import 'non_inventory_transaction_info.dart';
import 'user_transaction_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NonInventoryTransactions extends StatefulWidget {
  final String name;
  final bool isSupplier;
  final int userID;
  const NonInventoryTransactions(
      {required this.name,
      required this.userID,
      this.isSupplier = false,
      Key? key})
      : super(key: key);

  @override
  _NonInventoryTransactionsState createState() =>
      _NonInventoryTransactionsState();
}

class _NonInventoryTransactionsState extends State<NonInventoryTransactions> {
  List data = [];
  List dataTemp = [];
  Tuple4<num, num, num, num> totals =
      const Tuple4<num, num, num, num>(0, 0, 0, 0);
  Tuple4<num, num, num, num> totalsTemp =
      const Tuple4<num, num, num, num>(0, 0, 0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  final jWTToken = Hive.box('adminInfo').get('token');
  bool isLoading = true;
  @override
  void initState() {
    final transactionBloc = BlocProvider.of<TransactionsBloc>(context);
    transactionBloc.add(
      GetTransactionDetailsEvent(
        queryType:
            widget.isSupplier ? 'supplierInvoices' : 'nonInventoryInvoices',
        isFilter: false,
        token: jWTToken,
        userID: widget.userID.toString(),
      ),
    );
    // TODO: implement initState
    // for (var element in widget.data) {
    //   data.add(element);
    //   dataTemp.add(element);
    //   // if (element.containsKey('isSupplierInvoice')) {
    //   //
    //   // } else {
    //   //   element['shop'].forEach((shop) {
    //   //     if (shop['businessName'] == widget.name) {
    //   //       shop['invoiceNo'] = element['invoiceNo'];
    //   //       shop['date'] = element['date'];
    //   //       data.add(shop);
    //   //       dataTemp.add(shop);
    //   //     }
    //   //   });
    //   // }
    // }
    // totalsTemp = tupleTotal(data, begin, end, false, widget.isSupplier);
    // totals = totalsTemp;
    super.initState();
  }

  initSearch(String value) {
    if (value.isEmpty) {
      setState(
        () {
          dataTemp = data;
        },
      );
    }
    final items = data.where((element) {
      final invoiceIdLower = element['invoiceNo'].toLowerCase();
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

  bool showPaid = true;
  bool showDue = true;
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
            data.clear();
            dataTemp.clear();
            print(result);
            totals = Tuple4(
                result!['totalPaid'] ?? 0,
                result['totalDue'] ?? 0,
                result['buyingAmount'] ?? 0,
                !widget.isSupplier ? result['salesAmount'] ?? 0 : 0);
            totalsTemp = totals;
            data = result['invoices'].toList();
            dataTemp = data.toList();
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
                  });
                  final transactionBloc =
                      BlocProvider.of<TransactionsBloc>(context);
                  transactionBloc.add(
                    GetTransactionDetailsEvent(
                      queryType: widget.isSupplier
                          ? 'supplierInvoices'
                          : 'nonInventoryInvoices',
                      isFilter: false,
                      token: jWTToken,
                      userID: widget.userID.toString(),
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
                heightFactor: 0.76,
                child: SingleChildScrollView(
                  // padding: EdgeInsets.all(15.0),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                            Text(
                              widget.isSupplier
                                  ? 'Total Payment'
                                  : 'Total Sales',
                              style: kDrawerTextStyle1,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                nonInventoryDateWidget(
                                  color: kBackgroundColor,
                                  borderColor: kBackgroundColor,
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
                                nonInventoryDateWidget(
                                    color: kBackgroundColor,
                                    borderColor: kBackgroundColor,
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
                                        queryType: widget.isSupplier
                                            ? 'supplierInvoices'
                                            : 'nonInventoryInvoices',
                                        isFilter: true,
                                        token: jWTToken,
                                        begin: dateToJson(
                                            Timestamp.fromDate(begin)),
                                        end:
                                            dateToJson(Timestamp.fromDate(end)),
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
                                'Invoice No',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            DataColumn(
                              onSort: (i, value) {
                                setState(() {
                                  showPaid = !showPaid;
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
                                });
                              },
                              label: const Text(
                                'Due',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            const DataColumn(
                              label: Text(
                                'Buying',
                                style: kTotalSalesStyle,
                              ),
                            ),
                            if (!widget.isSupplier)
                              const DataColumn(
                                label: Text(
                                  'Amount',
                                  style: kTotalSalesStyle,
                                ),
                              ),
                          ],
                          rows: List.generate(dataTemp.length, (index) {
                            int counter = index;
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
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return NonInventoryInfo(
                                            data: dataTemp[index],
                                            date: dateFromJson(
                                                dataTemp[index]['createdAt']),
                                            invoiceId: dataTemp[index]
                                                    ['invoiceNo']
                                                .toString(),
                                            isSupplierPay: widget.isSupplier,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
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
                                    dataTemp[index]['buyPrice'].toString(),
                                    style: kTotalTextStyle,
                                  ),
                                ),
                                if (!widget.isSupplier)
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
                  child: Column(
                    children: [
                      LimitedBox(
                        maxHeight: 140,
                        child: GridView(
                          // physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 1,
                          ),
                          children: [
                            showPaid == true
                                ? SpecialContainer(
                                    value: totalsTemp.item1.toString(),
                                    title: 'Total Paid',
                                    color: kNewTextColor,
                                  )
                                : const SizedBox(),
                            showDue == true
                                ? SpecialContainer(
                                    value: totalsTemp.item2.toString(),
                                    title: 'Total Due',
                                    color: kRedColor,
                                  )
                                : const SizedBox(),
                            SpecialContainer(
                              value: totalsTemp.item3.toString(),
                              title: 'Buying Amount',
                              color: kNewTextColor,
                            ),
                            if (!widget.isSupplier)
                              SpecialContainer(
                                value: totalsTemp.item4.toString(),
                                title: 'Sales Amount',
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
                                  email: dataTemp[0]['supplierInfo']['email'] ??
                                      '',
                                  mobile: dataTemp[0]['supplierInfo']['mobile'],
                                  address: dataTemp[0]['supplierInfo']
                                      ['address'],
                                  isInventory: false,
                                  items: data,
                                  begin: begin,
                                  end: end,
                                  isSupplier: widget.isSupplier,
                                  totalSale: totalsTemp.item4.toString(),
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
                                email:
                                    dataTemp[0]['supplierInfo']['email'] ?? '',
                                mobile: dataTemp[0]['supplierInfo']['mobile'],
                                address: dataTemp[0]['supplierInfo']['address'],
                                isInventory: false,
                                isSupplier: widget.isSupplier,
                                items: data,
                                begin: begin,
                                end: end,
                                totalSale: totalsTemp.item4.toString(),
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
                                    email: dataTemp[0]['supplierInfo']
                                            ['email'] ??
                                        '',
                                    mobile: dataTemp[0]['supplierInfo']
                                        ['mobile'],
                                    address: dataTemp[0]['supplierInfo']
                                        ['address'],
                                    isInventory: false,
                                    items: data,
                                    begin: begin,
                                    isSupplier: widget.isSupplier,
                                    end: end,
                                    totalSale: totalsTemp.item4.toString(),
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

Tuple4<num, num, num, num> tupleTotal(
    List items, DateTime begin, DateTime end, bool isDate, bool isSupplierPay) {
  num sale = 0, due = 0, paid = 0, buy = 0;
  if (isDate == true) {
    for (var element in items) {
      Timestamp timestamp = dateFromJson(element['createdAt']);
      DateTime date = timestamp.toDate();
      begin = DateTime(begin.year, begin.month, begin.day);
      end = DateTime(end.year, end.month, end.day);
      DateTime dateFormatted = DateTime(date.year, date.month, date.day);
      if ((begin.isAfter(dateFormatted) ||
              begin.isAtSameMomentAs(dateFormatted)) &&
          (end.isBefore(dateFormatted) ||
              end.isAtSameMomentAs(dateFormatted))) {
        paid += element['paid'];
        due += element['due'];
        buy += element['buyPrice'];
        if (!isSupplierPay) {
          sale += element['price'];
        }
      }
    }
  } else {
    for (var element in items) {
      paid += element['paid'];
      due += element['due'];
      buy += element['buyPrice'];
      if (!isSupplierPay) {
        sale += element['price'];
      }
    }
  }
  Tuple4<num, num, num, num> data =
      Tuple4<num, num, num, num>(paid, due, buy, sale);
  return data;
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

Widget nonInventoryDateWidget({
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

// Widget searchBar() {
//   return Row(
//     children: [
//       Container(
//         width: 170.0,
//         height: 50.0,
//         padding: EdgeInsets.all(10.0),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: kBackgroundColor,
//             width: 3.0,
//           ),
//           borderRadius: BorderRadius.circular(20.0),
//         ),
//         child: Center(
//           child: TextField(
//             cursorColor: kBackgroundColor,
//             textAlign: TextAlign.center,
//             textAlignVertical: TextAlignVertical.center,
//             decoration: InputDecoration(
//               hintText: 'Search',
//               hintStyle: TextStyle(
//                 fontFamily: 'SourceSans',
//                 fontSize: 15.0,
//                 color: kBackgroundColor,
//                 letterSpacing: 1.3,
//               ),
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       ),
//       SizedBox(
//         width: 20.0,
//       ),
//       roundedTextButton(
//         borderColor: kBackgroundColor,
//         textColor: kBackgroundColor,
//       ),
//     ],
//   );
// }
