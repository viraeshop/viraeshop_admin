import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/generate_statement.dart';
import 'package:viraeshop_admin/configs/invoices/customer_goods_invoice.dart';
import 'package:viraeshop_admin/configs/invoices/print_customer_invoice.dart';
import 'package:viraeshop_admin/configs/invoices/share_customer_statement.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_admin/screens/transactions/user_transaction_screen.dart';

import '../due/due_receipt.dart';
import '../reciept_screen.dart';

class CustomerTransactionScreen extends StatefulWidget {
  final String name;
  final List data;
 const CustomerTransactionScreen({required this.data, required this.name, Key? key}) : super(key: key);

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
  @override
  void initState() {
    // TODO: implement initState
    num totalPaid = 0, totalDue = 0, totalAmount = 0;
    for (var element in widget.data) {
      totalPaid += element['paid'];
      if(element['paid'] == 0 && element['advance'] != 0){
        totalPaid += element['advance'];
      }
      totalDue += element['due'];
      totalAmount += element['price'];
    }
    setState(() {
      data = widget.data;
      dataTemp = data;
      totals = Tuple3<num, num, num>(totalPaid, totalDue, totalAmount);
      totalsTemp = totals;
    });
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
    return Scaffold(
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
                                  dataTemp = dateTupleList(data, begin, end);
                                  totalsTemp = tuple(data, begin, end);
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
                            'Invoice No.',
                            style: kTotalSalesStyle,
                          ),
                        ),
                        DataColumn(
                          onSort: (i, value) {
                            setState(() {
                              showPaid = !showPaid;
                              showDue = !showDue;
                              if(showDue){
                                showDue = false;
                              }
                              if(showPaid){
                                dataTemp = data.where((element) => element['paid'] != 0).toList();
                              }else{
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
                              if(showPaid){
                                showPaid = false;
                              }
                              if(showDue){
                                dataTemp = data.where((element) => element['due'] != 0).toList();
                              }else{
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
                      rows: List.generate(
                          dataTemp.length, (index) {
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
                                '${dataTemp[index]['invoice_id']}',
                                style: kCustomerCellStyle,
                              ),
                                onTap: () {
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
                                }
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 1,
                        ),
                        children: [
                          showDue ? const SizedBox() : SpecialContainer(
                            value: totalsTemp.item1.toString(),
                            title: 'Total Paid',
                            color: kNewTextColor,
                          ),
                         showPaid ? const SizedBox() : SpecialContainer(
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
                            try{
                              shareCustomerStatement(
                                name: widget.name,
                                email: dataTemp[0]['user_info']['email'] ?? '',
                                mobile: dataTemp[0]['user_info']['mobile'],
                                address: dataTemp[0]['user_info']['address'],
                                isInventory: true,
                                items: data,
                                begin: begin,
                                end: end,
                                totalAmount: totalsTemp.item3.toString(),
                                totalDue: totalsTemp.item2.toString(),
                                totalPay: totalsTemp.item1.toString(),
                                isSave: true,
                              );
                              toast(context: context, title: 'Saved', color: kNewMainColor);
                            }catch (e){
                              if(kDebugMode){
                                print(e);
                              }
                            }
                          },
                        ),
                        buttons(
                          onTap: () {
                            shareCustomerStatement(
                              name: widget.name,
                              email: dataTemp[0]['user_info']['email'] ?? '',
                              mobile: dataTemp[0]['user_info']['mobile'],
                              address: dataTemp[0]['user_info']['address'],
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
                                email: dataTemp[0]['user_info']['email'] ?? '',
                                mobile: dataTemp[0]['user_info']['mobile'],
                                address: dataTemp[0]['user_info']['address'],
                                isInventory: true,
                                items: data,
                                begin: begin,
                                end: end,
                                totalAmount: totalsTemp.item3.toString(),
                                totalDue: totalsTemp.item2.toString(),
                                totalPay: totalsTemp.item1.toString(),
                                isPrint: true
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
        ],
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
    Timestamp timestamp = element['date'];
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      paid += element['paid'];
      if(element['paid'] == 0 && element['advance'] != 0){
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
    Timestamp timestamp = element['date'];
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
