import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/generate_statement.dart';
import 'package:viraeshop_admin/configs/pos_printer.dart';
import 'package:viraeshop_admin/configs/print_statement.dart';
import 'package:viraeshop_admin/configs/share_statement.dart';
import 'package:viraeshop_admin/reusable_widgets/transaction_details.dart';
import 'package:viraeshop_admin/screens/non_inventory_transactions.dart';

import 'customer_transactions.dart';

class UserTransactionScreen extends StatefulWidget {
  final String name;
  final List data;
  UserTransactionScreen({required this.data, required this.name});

  @override
  _UserTransactionScreenState createState() => _UserTransactionScreenState();
}

class _UserTransactionScreenState extends State<UserTransactionScreen> {
  Map<String, List> transactionData = {};
  Map<String, List> tempTransactionData = {};
  Map<String, Tuple3> balances = {};
  Map<String, Tuple3> balancesTemp = {};
  Tuple3<num, num, num> totalBalance = Tuple3<num, num, num>(0, 0, 0);
  Tuple3<num, num, num> totalBalanceTemp = Tuple3<num, num, num>(0, 0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  Set customers = Set();

  @override
  void initState() {
    // TODO: implement initState
    List customerId = [];
    widget.data.forEach((element) {
      customerId.add(element['customer_id']);
    });
    Set customerSet = Set.from(customerId);
    customerSet.forEach((customer) {
      List items = [];
      widget.data.forEach((element) {
        if (element['customer_id'] == customer) {
          items.add(element);
        }
      });
      setState(() {
        transactionData[customer] = items;
        tempTransactionData[customer] = items;
      });
    });
    setState(() {
      balances = Map.fromIterable(
        customerSet,
        key: (element) => element,
        value: (element) {
          return tuple(transactionData[element]!);
        },
      );
      balancesTemp = balances;
      totalBalance = tuple(widget.data);
      totalBalanceTemp = totalBalance;
      customers = customerSet;
    });
    super.initState();
  }

  initSearch(String value) {
    if (value.length == 0) {
      setState(
        () {
          balancesTemp = balances;
          tempTransactionData = transactionData;
        },
      );
    }
    customers.forEach((customer) {
      List items = widget.data.where((element) {
        final nameLower = element['user_info']['name'].toLowerCase();
        final valueLower = value.toLowerCase();
        return nameLower.contains(valueLower);
      }).toList();
      setState(() {
        tempTransactionData[customer] = items;
      });
    });
    setState(() {
      this.balancesTemp = Map.fromIterable(
        customers,
        key: (element) => element,
        value: (element) {
          return tuple(tempTransactionData[element]!);
        },
      );
    });
  }

  bool showPaid = true;
  bool showDue = true;
  @override
  Widget build(BuildContext context) {
    print(transactionData);
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40.0,
        backgroundColor: kSubMainColor,
        elevation: 0.0,
        shape: Border(
          bottom: BorderSide(
            color: kSubMainColor,
          ),
        ),
        title: Text(
          '${widget.name}',
          style: kDrawerTextStyle2,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            FontAwesomeIcons.chevronLeft,
          ),
          color: kBackgroundColor,
          iconSize: 20.0,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                balancesTemp = balances;
                totalBalanceTemp = totalBalance;
                tempTransactionData = transactionData;
              });
            },
            icon: Icon(Icons.refresh),
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
              heightFactor: 0.67,
              child: SingleChildScrollView(
                // padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Container(
                      height: 160.0,
                      width: screenSize.width,
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: kSubMainColor,
                        border: Border(
                            // bottom: BorderSide(color: kBackgroundColor,),
                            ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Sales',
                            style: kDrawerTextStyle1,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              dateWidget(
                                borderColor: kBackgroundColor,
                                color: kBackgroundColor,
                                title: '${begin.toString().split(' ')[0]}',
                                onTap: () {
                                  buildMaterialDatePicker(context, true);
                                },
                              ),
                              Icon(
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
                              SizedBox(
                                width: 20.0,
                              ),
                              roundedTextButton(
                                  borderColor: kBackgroundColor,
                                  textColor: kBackgroundColor,
                                  onTap: () {
                                    setState(() {
                                      balancesTemp = Map.fromIterable(
                                        customers,
                                        key: (element) => element,
                                        value: (element) {
                                          return dateTuple(
                                              transactionData[element]!,
                                              begin,
                                              end);
                                        },
                                      );
                                      totalBalanceTemp =
                                          dateTuple(widget.data, begin, end);
                                    });
                                  }),
                            ],
                          ),
                          SizedBox(
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
                          DataColumn(
                            label: Text(
                              'SL',
                              style: kTotalSalesStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Customer name/ID',
                              style: kTotalSalesStyle,
                            ),
                          ),
                          DataColumn(
                            onSort: (i, value) {
                              setState(() {
                                showPaid = !showPaid;
                              });
                            },
                            label: Text(
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
                            label: Text(
                              'Due',
                              style: kTotalSalesStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Amount',
                              style: kTotalSalesStyle,
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Action',
                              style: kTotalSalesStyle,
                            ),
                          ),
                        ],
                        rows: List.generate(balancesTemp.keys.toList().length,
                            (index) {
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
                                  '${tempTransactionData[
                                  tempTransactionData.keys
                                      .toList()[index]]![0]['user_info']['name']}',
                                  style: kCustomerCellStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${balancesTemp[balancesTemp.keys.toList()[index]]!.item1.toString()}',
                                  style: kTotalTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${balancesTemp[balancesTemp.keys.toList()[index]]!.item2.toString()}',
                                  style: kDueCellStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${balancesTemp[balancesTemp.keys.toList()[index]]!.item3.toString()}',
                                  style: kTotalTextStyle,
                                ),
                              ),
                              DataCell(
                                  Text(
                                    'View',
                                    style: kTotalTextStyle,
                                  ), onTap: () {
                                // print(tempTransactionData);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return CustomerTransactionScreen(
                                        data: tempTransactionData[
                                            tempTransactionData.keys
                                                .toList()[index]]!,
                                        name: tempTransactionData[
                                        tempTransactionData.keys
                                            .toList()[index]]![0]['user_info']['name'],
                                      );
                                    },
                                  ),
                                );
                              }),
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
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    LimitedBox(
                      maxHeight: 140,
                      child: GridView(
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 1,
                        ),
                        children: [
                         showPaid == true ? SpecialContainer(
                            value: '${totalBalanceTemp.item1.toString()}',
                            title: 'Total Paid',
                            color: kNewTextColor,
                          ) : SizedBox(),
                         showDue == true ? SpecialContainer(
                            value: totalBalanceTemp.item2.toString(),
                            title: 'Total Due',
                            color: kRedColor,
                          ) : SizedBox(),
                          SpecialContainer(
                            value: '${totalBalanceTemp.item3.toString()}',
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
                            generateStatement(
                                items: balances,
                                begin: begin,
                                name: widget.name,
                                end: end,
                                totalAmount: totalBalanceTemp.item3.toString(),
                                totalDue: totalBalanceTemp.item2.toString(),
                                totalPay: totalBalanceTemp.item1.toString());
                          },
                        ),
                        buttons(
                          onTap: () {
                            shareStatement(
                                items: balances,
                                begin: begin,
                                end: end,
                                totalAmount: totalBalanceTemp.item3.toString(),
                                totalDue: totalBalanceTemp.item2.toString(),
                                totalPay: totalBalanceTemp.item1.toString());
                          },
                          title: 'Share',
                        ),
                        buttons(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PosPrinter(address: '', advance: '', discountAmount: '', due: '', invoiceId: '', items: [], mobile: '', name: '', paid: '', quantity: '', subTotal: '',),),);
                            //   printStatement(
                            //       items: balances,
                            //       begin: begin,
                            //       end: end,
                            //       totalAmount:
                            //           totalBalanceTemp.item3.toString(),
                            //       totalDue: totalBalanceTemp.item2.toString(),
                            //       totalPay: totalBalanceTemp.item1.toString());
                            // },
                            // title: 'Print'),
                            },),
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

Tuple3<num, num, num> tuple(List items) {
  num sale = 0, due = 0, paid = 0;
  items.forEach((element) {
    paid += element['paid'];
    sale += element['price'];
    due += element['due'];
  });
  Tuple3<num, num, num> data = Tuple3<num, num, num>(paid, due, sale);
  return data;
}

Tuple3<num, num, num> dateTuple(List items, DateTime begin, DateTime end) {
  num sale = 0, due = 0, paid = 0;
  items.forEach((element) {
    Timestamp timestamp = element['date'];
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      paid += element['paid'];
      sale += element['price'];
      due += element['due'];
    }
  });
  Tuple3<num, num, num> data = Tuple3<num, num, num>(paid, due, sale);
  return data;
}

// ignore: avoid_init_to_null
Widget buttons({String title = '', var width = null, var onTap = null}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: width,
      padding: EdgeInsets.all(10.0),
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
          style: TextStyle(
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
    padding: EdgeInsets.all(5.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4.0),
    ),
    child: Row(
      children: [
        Text(
          title,
          style: TextStyle(
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
      padding: EdgeInsets.all(5.0),
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
