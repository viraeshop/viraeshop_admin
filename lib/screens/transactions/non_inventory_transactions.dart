import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/invoices/customer_goods_invoice.dart';
import 'package:viraeshop_admin/configs/invoices/print_customer_invoice.dart';
import 'package:viraeshop_admin/configs/invoices/share_customer_statement.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';

import '../customer_transactions.dart';
import 'non_inventory_transaction_info.dart';
import 'user_transaction_screen.dart';

class NonInventoryTransactions extends StatefulWidget {
  final String name;
  final List data;
  NonInventoryTransactions({required this.data, required this.name});

  @override
  _NonInventoryTransactionsState createState() =>
      _NonInventoryTransactionsState();
}

class _NonInventoryTransactionsState extends State<NonInventoryTransactions> {
  List data = [], initialData = [];
  List dataTemp = [];
  Tuple4<num, num, num, num> totals = const Tuple4<num, num, num, num>(0, 0, 0, 0);
  Tuple4<num, num, num, num> totalsTemp =
      const Tuple4<num, num, num, num>(0, 0, 0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    initialData = widget.data;
    widget.data.forEach((element) {
      element['shop'].forEach((shop) {
        if (shop['business_name'] == widget.name) {
          shop['invoice_id'] = element['invoice_id'];
          shop['date'] = element['date'];
          data.add(shop);
          dataTemp.add(shop);
        }
      });
    });
    totalsTemp = tupleTotal(data, begin, end, false);
    totals = totalsTemp;
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
      final invoiceIdLower = element['invoice_id'].toLowerCase();
      final valueLower = value.toLowerCase();
      return invoiceIdLower.contains(valueLower);
    }).toList();
    final List filtered = [];
    items.forEach((element) {
      filtered.add(element);
    });
    setState(() {
      this.dataTemp = filtered;
    });
  }

  bool showPaid = true;
  bool showDue = true;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40.0,
        backgroundColor: kSubMainColor,
        elevation: 0.0,
        shape: const Border(
          bottom: const BorderSide(
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
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: 0.8,
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
                                    dataTemp = dateTupleList(data, begin, end);
                                    totalsTemp =
                                        tupleTotal(data, begin, end, true);
                                  });
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
                                  '${dataTemp[index]['invoice_id']}',
                                  style: kCustomerCellStyle,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return NonInventoryInfo(
                                          data: dataTemp[index],
                                          date: dataTemp[index]['date'],
                                          invoiceId: dataTemp[index]
                                          ['invoice_id'],
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
                                  dataTemp[index]['buy_price'].toString(),
                                  style: kTotalTextStyle,
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
              heightFactor: 0.31,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    LimitedBox(
                      maxHeight: 140,
                      child: GridView(
                        // physics: NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            generateCustomerStatement(
                              name: dataTemp[0]['name'],
                              email: dataTemp[0]['email'],
                              mobile: dataTemp[0]['mobile'],
                              address: dataTemp[0]['address'],
                              items: data,
                              begin: begin,
                              end: end,
                              isInventory: true,
                              totalSale: totalsTemp.item3.toString(),
                              totalAmount: totalsTemp.item4.toString(),
                              totalDue: totalsTemp.item2.toString(),
                              totalPay: totalsTemp.item1.toString(),
                            );
                          },
                        ),
                        buttons(
                          onTap: () {
                            shareCustomerStatement(
                              name: dataTemp[0]['name'],
                              email: dataTemp[0]['email'],
                              mobile: dataTemp[0]['mobile'],
                              address: dataTemp[0]['address'],
                              items: data,
                              begin: begin,
                              end: end,
                              isInventory: true,
                              totalSale: totalsTemp.item3.toString(),
                              totalAmount: totalsTemp.item4.toString(),
                              totalDue: totalsTemp.item2.toString(),
                              totalPay: totalsTemp.item1.toString(),
                            );
                          },
                          title: 'Share',
                        ),
                        buttons(
                            onTap: () {
                              printCustomerStatement(
                                name: dataTemp[0]['name'],
                                email: dataTemp[0]['email'],
                                mobile: dataTemp[0]['mobile'],
                                address: dataTemp[0]['address'],
                                isInventory: true,
                                items: data,
                                begin: begin,
                                end: end,
                                totalSale: totalsTemp.item3.toString(),
                                totalAmount: totalsTemp.item4.toString(),
                                totalDue: totalsTemp.item2.toString(),
                                totalPay: totalsTemp.item1.toString(),
                              );
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

Tuple4<num, num, num, num> tupleTotal(
    List items, DateTime begin, DateTime end, bool isDate) {
  num sale = 0, due = 0, paid = 0, buy = 0;
  if (isDate == true) {
    items.forEach((element) {
      Timestamp timestamp = element['date'];
      DateTime date = timestamp.toDate();
      begin = DateTime(begin.year, begin.month, begin.day);
      end = DateTime(end.year, end.month, end.day);
      DateTime dateFormatted = DateTime(date.year, date.month, date.day);
      if ((begin.isAfter(dateFormatted) ||
              begin.isAtSameMomentAs(dateFormatted)) &&
          (end.isBefore(dateFormatted) ||
              end.isAtSameMomentAs(dateFormatted))) {
        paid += element['paid'];
        sale += element['price'];
        due += element['due'];
        buy += element['buy_price'];
      }
    });
  } else {
    items.forEach((element) {
      paid += element['paid'];
      sale += element['price'];
      due += element['due'];
      buy += element['buy_price'];
    });
  }
  Tuple4<num, num, num, num> data =
      Tuple4<num, num, num, num>(paid, due, buy, sale);
  return data;
}

// ignore: avoid_init_to_null
// Widget buttons({String title = '', var width = null}) {
//   return Container(
//     width: width,
//     padding: EdgeInsets.all(5.0),
//     decoration: BoxDecoration(
//       border: Border.all(
//         color: kBlackColor,
//         width: 2.0,
//       ),
//       borderRadius: BorderRadius.circular(30.0),
//     ),
//     child: Center(
//       child: Text(
//         title,
//         style: TextStyle(
//           fontFamily: 'SourceSans',
//           fontSize: 12.0,
//           color: kBlackColor,
//           letterSpacing: 1.3,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   );
// }

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
