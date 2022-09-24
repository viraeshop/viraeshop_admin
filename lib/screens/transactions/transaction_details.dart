import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/transactions/employees_transactions.dart';
import 'package:viraeshop_admin/screens/transactions/group_transactions.dart';
import 'package:viraeshop_admin/screens/transactions/non_inventory_transactions.dart';
import 'package:viraeshop_admin/screens/transactions/noninventory_tranzacs.dart';
import 'package:viraeshop_admin/screens/transactions/user_transaction_screen.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

class TransactionDetails extends StatefulWidget {
  static String path = '/transactions';
  const TransactionDetails({Key? key}) : super(key: key);

  @override
  _TransactionDetailsState createState() => _TransactionDetailsState();
}

class _TransactionDetailsState extends State<TransactionDetails> {
  List employCus = [];
  List transactionData = [];
  List nonInventory = [];
  List supplierInvoices = [];
  GeneralCrud generalCrud = GeneralCrud();
  int percentageCounter(num value, total) {
    num percent = 0;
    if (value != 0 && total != 0 || total != 0) {
      percent = (value / total) * 360;
    }
    return percent.toInt();
  }

  num sumTotal(Tuple5<num, num, num, num, num> items) {
    num sum =
        items.item1 + items.item2 + items.item3 + items.item4 + items.item5;
    return sum;
  }

  Tuple6<String, String, String, String, String, String> groupTuple =
      const Tuple6('0', '0', '0', '0', '0', '0');
  Tuple6<String, String, String, String, String, String> groupTupleTemp =
  const Tuple6('0', '0', '0', '0', '0', '0');
  Tuple5<num, num, num, num, num> totals =
      const Tuple5<num, num, num, num, num>(0, 0, 0, 0, 0);
  Tuple5<num, num, num, num, num> totalsTemp =
      const Tuple5<num, num, num, num, num>(0, 0, 0, 0, 0);
  int salesPercent = 0,
      duePercent = 0,
      paidPercent = 0,
      expensePercent = 0,
      profitPercent = 0;
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    generalCrud.getTransaction().then((snapshot) async {
      setState(() {
        isLoading = true;
      });
      final data = snapshot.docs;
      Map<String, num> totalTemp = {
        'totalSales': 0,
        'totalDue': 0,
        'totalPaid': 0,
        'totalExpense': 0,
        'totalProfit': 0,
      };
      num empCusSales = 0,
          empCusDue = 0,
          nonInventorySales = 0,
          nonInventoryDue = 0,
          supplierPaid = 0,
          supplierDue = 0;
      for (var element in data) {
        transactionData.add(element.data());
        final invoice = element.data() as Map<String, dynamic>;
        if(!invoice.containsKey('isSupplierInvoice')){
          if (element.get('isWithNonInventory') == true) {
            nonInventory.add(element.data());
            element.get('shop').forEach((shop) {
              nonInventorySales += shop['price'];
              nonInventoryDue += shop['due'];
              totalTemp.update('totalProfit', (value) {
                return value + shop['profit'];
              });
              totalTemp.update('totalPaid', (value) {
                return value + shop['paid'];
              });
              totalTemp.update('totalDue', (value) {
                return value + shop['due'];
              });
            });
          }
          employCus.add(element.data());
          empCusSales += element.get('price');
          empCusDue += element.get('due');
          totalTemp.update('totalSales', (value) {
            return value + element.get('price');
          });
          totalTemp.update('totalProfit', (value){
            return value + element.get('profit');
          });
          if(element.get('paid') == 0 && element.get('advance') != 0){
            totalTemp.update('totalPaid', (value) {
              return value + element.get('advance');
            });
          }
        }else{
          supplierInvoices.add(invoice);
          supplierPaid += invoice['paid'];
          supplierDue += invoice['due'];
        }
        totalTemp.update('totalDue', (value) {
          return value + element.get('due');
        });
        totalTemp.update('totalPaid', (value) {
          return value + element.get('paid');
        });
      }
      await generalCrud.getExpenses().then((snapshot) {
        isLoading = false;
        final data = snapshot.docs;
        for (var element in data) {
          //setState(() {
          transactionData.add(element.data());
          //});
          totalTemp.update('totalExpense', (value) {
            return value + element.get('cost');
          });
        }
      }).catchError((error) {
        isLoading = false;
        print(error);
      });
      groupTuple = Tuple6(
        empCusSales.toString(),
        empCusDue.toString(),
        nonInventorySales.toString(),
        nonInventoryDue.toString(),
        supplierPaid.toString(),
        supplierDue.toString(),
      );
      //setState((){
      groupTupleTemp = groupTuple;
      //});
      totals = Tuple5<num, num, num, num, num>(
          totalTemp['totalSales']!,
          totalTemp['totalDue']!,
          totalTemp['totalPaid']!,
          totalTemp['totalExpense']!,
          totalTemp['totalProfit']!);
      setState(() {
        totalsTemp = totals;
        num totalValue = sumTotal(totals);
        salesPercent = percentageCounter(totals.item1, totalValue);
        duePercent = percentageCounter(totals.item2, totalValue);
        paidPercent = percentageCounter(totals.item3, totalValue);
        expensePercent = percentageCounter(totals.item4, totalValue);
        profitPercent = percentageCounter(totals.item5, totalValue);
        isLoading = false;
      });
      print('Total Invoices: ${transactionData.length}');
    }).catchError((error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const SizedBox(
        height: 100.0,
        width: 100.0,
        child: LoadingIndicator(
          indicatorType: Indicator.lineScale,
          colors: [kMainColor, kBlueColor, kRedColor, kYellowColor],
          strokeWidth: 2,
        ),
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Transactions',
            style: kAppBarTitleTextStyle,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          elevation: 0.0,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  groupTupleTemp = groupTuple;
                  totalsTemp = totals;
                  num totalValue = sumTotal(totals);
                  salesPercent = percentageCounter(totals.item1, totalValue);
                  duePercent = percentageCounter(totals.item2, totalValue);
                  paidPercent = percentageCounter(totals.item3, totalValue);
                  expensePercent = percentageCounter(totals.item4, totalValue);
                  profitPercent = percentageCounter(totals.item5, totalValue);
                  isLoading = false;
                });
              },
              icon: const Icon(Icons.refresh),
              color: kSubMainColor,
              iconSize: 30.0,
            ),
          ],
        ),
        body: isLoading
            ? Container()
            : Container(
                color: kBackgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      InfoWidget(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Employees(data: employCus),
                            ),
                          );
                        },
                        title: 'Employees',
                        textWidget: rowWidget(
                            groupTupleTemp.item1, groupTupleTemp.item2),
                      ),
                      InfoWidget(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NonInventoryTransactionShops(
                                      data: nonInventory),
                            ),
                          );
                        },
                        title: 'Non-Inventory Items',
                        textWidget: rowWidget(
                            groupTupleTemp.item3, groupTupleTemp.item4),
                      ),
                      /// Supplier
                      InfoWidget(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NonInventoryTransactionShops(
                                      data: supplierInvoices,
                                  isSupplier: true,
                                  ),
                            ),
                          );
                        },
                        title: 'Suppliers Transactions',
                        textWidget: rowWidget(
                            groupTupleTemp.item5, groupTupleTemp.item6, 'Payments'),
                      ),
                      InfoWidget(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GroupTransactions(data: employCus),
                            ),
                          );
                        },
                        title: 'Customers',
                        textWidget: rowWidget(
                            groupTupleTemp.item1, groupTupleTemp.item2),
                      ),

                      ///Pie chart will be here
                      SizedBox(
                        height: 220.0,
                        width: double.infinity,
                        child: SfCircularChart(
                            // title: ChartTitle(
                            //   text: 'Transactions',
                            //   textStyle: kTotalSalesStyle,
                            // ),
                            legend: Legend(
                              textStyle: kTotalTextStyle,
                              isVisible: true,
                              iconHeight: 20.0,
                              iconWidth: 20.0,
                              title: LegendTitle(
                                text: 'Transactions',
                                textStyle: kTotalSalesStyle,
                                alignment: ChartAlignment.center,
                              ),
                            ),
                            series: <CircularSeries>[
                              PieSeries<TransactionData, String>(
                                  dataSource: [
                                    TransactionData(
                                        x: 'Total Sales',
                                        y: salesPercent,
                                        color: kYellowColor),
                                    TransactionData(
                                        x: 'Total Due',
                                        y: duePercent,
                                        color: kRedColor),
                                    TransactionData(
                                      x: 'Total Paid',
                                      y: paidPercent,
                                      color: kNewTextColor,
                                    ),
                                    TransactionData(
                                      x: 'Total Expense',
                                      y: expensePercent,
                                      color: kBlueColor,
                                    ),
                                    TransactionData(
                                      x: 'TotalProfit',
                                      y: profitPercent,
                                      color: kNewMainColor,
                                    ),
                                  ],
                                  pointColorMapper: (TransactionData data, _) =>
                                      data.color,
                                  xValueMapper: (TransactionData data, _) =>
                                      data.x,
                                  yValueMapper: (TransactionData data, _) =>
                                      data.y),
                            ]),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          dateWidget(
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
                              onTap: () {
                                buildMaterialDatePicker(context, false);
                              },
                              title: end.isAtSameMomentAs(DateTime.now())
                                  ? 'To this date..'
                                  : end.toString().split(' ')[0]),
                          const SizedBox(
                            width: 20.0,
                          ),
                          roundedTextButton(onTap: () {
                            num totalValue = 0;
                            setState(() {
                              groupTupleTemp =
                                  dateTuple3(transactionData, begin, end);
                              totalsTemp =
                                  dateTotalTuple(transactionData, begin, end);
                              totalValue = sumTotal(totalsTemp);
                              salesPercent = percentageCounter(
                                  totalsTemp.item1, totalValue);
                              duePercent = percentageCounter(
                                  totalsTemp.item2, totalValue);
                              paidPercent = percentageCounter(
                                  totalsTemp.item3, totalValue);
                              expensePercent = percentageCounter(
                                  totalsTemp.item4, totalValue);
                              profitPercent = percentageCounter(
                                  totalsTemp.item5, totalValue);
                            });
                          }),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      LimitedBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                        child: GridView(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 35 / 25.0,
                          ),
                          children: [
                            SpecialContainer(
                              value: totalsTemp.item1.toString(),
                              title: 'Total Sales',
                              color: kYellowColor,
                            ),
                            SpecialContainer(
                              value: totalsTemp.item2.toString(),
                              title: 'Total Due',
                              color: kRedColor,
                            ),
                            SpecialContainer(
                              value: totalsTemp.item3.toString(),
                              title: 'Total Paid',
                              color: kNewTextColor,
                            ),
                            SpecialContainer(
                              value: totalsTemp.item4.toString(),
                              title: 'Total Expense',
                              color: kBlueColor,
                            ),
                            SpecialContainer(
                              value: totalsTemp.item5.toString(),
                              title: 'Total Profit',
                              color: kMainColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

Tuple5<num, num, num, num, num> dateTotalTuple(
    List items, DateTime begin, DateTime end) {
  num sale = 0, due = 0, expense = 0, paid = 0, profit = 0;
  //print('Date data: $items');
  List filter = [];
  items.forEach((element) {
    Timestamp timestamp = element['date'];
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      filter.add(element);
      // print('Invoice: ${element['invoice_id']}: $element');
      if (element.containsKey('cost')) {
        expense += element['cost'];
      } else {
        if(!element.containsKey('isSupplierInvoice')){
          if (element['isWithNonInventory']) {
            element['shop'].forEach((shop) {
              due += shop['due'];
              profit += shop['profit'];
              paid += shop['paid'];
            });
          }
          sale += element['price'];
          profit += element['profit'];
        }
        due += element['due'];
        paid += element['paid'];
      }
    }
  });
  print('Total filtered Invoices: ${filter.length}');
  Tuple5<num, num, num, num, num> data =
      Tuple5<num, num, num, num, num>(sale, due, paid, expense, profit);
  return data;
}

Tuple6<String, String, String, String, String, String> dateTuple3(
    List items, DateTime begin, DateTime end) {
  num inventorySale = 0,
      inventoryDue = 0,
      nonInventorySales = 0,
      nonInventoryDue = 0, supplierPaid = 0, supplierDue = 0;
  items.forEach((element) {
    Timestamp timestamp = element['date'];
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      if (element.containsValue('cost') == false) {
        if(element.containsKey('isSupplierInvoice')){
          supplierPaid += element['paid'];
          supplierDue += element['due'];
        }else{
          if (element['isWithNonInventory'] == true) {
            element['shop'].forEach((shop) {
              nonInventorySales += shop['price'];
              nonInventoryDue += shop['due'];
            });
          }
          inventorySale += element['price'];
          inventoryDue += element['due'];
        }
        }
    }
  });
  Tuple6<String, String, String, String, String, String> data =
      Tuple6<String, String, String, String, String, String>(
    inventorySale.toString(),
    inventoryDue.toString(),
    nonInventorySales.toString(),
    nonInventoryDue.toString(),
    supplierPaid.toString(),
    supplierDue.toString(),
  );
  return data;
}

/// Rounded TextButton

Widget roundedTextButton({
  Color borderColor = kMainColor,
  textColor = kBlackColor,
  // ignore: avoid_init_to_null
  dynamic onTap = null,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: Row(
          children: [
            Text(
              'GO',
              style: TextStyle(
                fontFamily: 'SourceSans',
                fontSize: 15.0,
                color: textColor,
                letterSpacing: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              color: textColor,
              size: 15.0,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Pie chart class
class TransactionData {
  final String x;
  final int y;
  final Color color;
  TransactionData({required this.x, required this.y, required this.color});
}

class InfoWidget extends StatelessWidget {
  final Widget textWidget;
  final String title;
  final void Function() onTap;
  InfoWidget(
      {required this.textWidget, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: screenSize.width,
        height: 130,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          // color: kStrokeColor,
          border: Border.all(
            color: kMainColor,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(9.0),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(alignment: Alignment.topRight, child: cardWidget(title)),
            Align(
              alignment: Alignment.center,
              child: Container(
                //width: 250.0,
                padding: const EdgeInsets.all(10),
                height: 60.0,
                //padding: EdgeInsets.only(top: 10.0),
                child: textWidget,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget cardWidget(String title) {
  return Container(
    width: 200.0,
    margin: const EdgeInsets.all(10.0),
    padding: const EdgeInsets.all(3.0),
    decoration: BoxDecoration(
      color: kMainColor,
      borderRadius: BorderRadius.circular(4.0),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: kStyleText,
        ),
      ],
    ),
  );
}

Widget rowWidget(String sales, due, [title = 'Sales']) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      specialText(title, sales),
      specialText('Due', due),
    ],
  );
}

Widget specialText(String title, value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        '$value BDT',
        style: kTotalSalesStyle,
      ),
      Text(
        'Total $title',
        style: kTotalTextStyle,
      ),
    ],
  );
}

class SpecialContainer extends StatelessWidget {
  final String value;
  final String title;
  final Color color;
  final double height, width;
  SpecialContainer(
      {required this.value,
      required this.title,
      required this.color,
      this.height: 130.0,
      this.width: 100.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(
          color: kMainColor,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(9.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$value BDT',
            style: kTotalSalesStyle,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Container(
            padding: const EdgeInsets.all(3.0),
            width: 120.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Text(
                title,
                style: kStyleText,
              ),
            ),
          )
        ],
      ),
    );
  }
}
