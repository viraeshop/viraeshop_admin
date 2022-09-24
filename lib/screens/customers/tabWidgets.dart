import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/screens/orders/order_info_view.dart';
import 'package:viraeshop_admin/screens/reciept_screen.dart';

import '../../configs/baxes.dart';
import '../transactions/customer_transactions.dart';
import '../due/due_receipt.dart';
import '../orders/order_tranz_card.dart';
import '../transactions/transaction_details.dart';

class SalesTab extends StatefulWidget {
  final String userId;
  bool? isAdmin;
  SalesTab({required this.userId, this.isAdmin = false});

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
  @override
  void initState() {
    // TODO: implement initState
    String filterField = widget.isAdmin == true ? 'employee_id' : 'customer_id';
    FirebaseFirestore.instance
        .collection('transaction')
        .where(filterField, isEqualTo: widget.userId)
        .orderBy('date', descending: true)
        .get()
        .then((snapshot) {
      final data = snapshot.docs;
      for (var element in data) {
        transactions.add(element.data());
        transactionBackup.add(element.data());
        invoiceNo.add(element.id);
        totalPaid += element.get('paid');
        if(element.get('paid') == 0 && element.get('advance') != 0){
          totalPaid += element.get('advance');
        }
        totalDue += element.get('due');
        totalAmount += element.get('price');
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: transactionBackup.isNotEmpty && isError == false
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
                                '${element['quantity']} X ${element['product_name']}, ';
                          }
                          Timestamp timestamp = transactions[i]['date'];
                          String date =
                              DateFormat.yMMMd().format(timestamp.toDate());
                          String customerName = transactions[i]['customer_role'] == 'general' ? transactions[i]['user_info']
                          ['name'] : transactions[i]['user_info']['business_name'] + '(${transactions[i]['user_info']['name']})';
                          return OrderTranzCard(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DueReceipt(
                                  title: 'Receipt',
                                  data: transactions[i],
                                  isOnlyShow: true,
                                );
                              }));
                            },
                            date: date,
                            price: transactions[i]['price'].toString(),
                            employeeName: transactions[i]['employee_name'],
                            customerName: customerName,
                            desc: description,
                            invoiceId: invoiceNo[i],
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
                              buildMaterialDatePicker(context, false);
                            },
                            title: end.isAtSameMomentAs(DateTime.now())
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
                                  if(element['paid'] == 0 && element['advance'] != 0){
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
                                if(element['paid'] == 0 && element['advance'] != 0){
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                       isDue ? const SizedBox() : GestureDetector(
                          onTap: (){
                            setState(() {
                              isPaid = !isPaid;
                              if(isPaid){
                                transactions = transactionBackup.where((element) => element['paid'] != 0).toList();
                              }else{
                                transactions = transactionBackup;
                              }
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                        isPaid ? const SizedBox() : GestureDetector(
                          onTap: (){
                            setState(() {
                              isDue = !isDue;
                              if(isDue){
                                transactions = transactionBackup.where((element) => element['due'] != 0).toList();
                              }else{
                                transactions = transactionBackup;
                              }
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
          : isLoading
              ? const Center(
                  child: SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: CircularProgressIndicator(
                        color: kMainColor,
                      )),
                )
              : const Center(
                  child: Text(
                    'May be You have\'nt made sale yet. or an error occured. Make sure you already made a sale or try again.',
                    textAlign: TextAlign.center,
                    style: kProductNameStyle,
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
  List orders = [];
  bool isLoading = true, isError = false;
  @override
  void initState() {
    // TODO: implement initState
    FirebaseFirestore.instance
        .collection('order')
        .where('customer_info.customer_id', isEqualTo: widget.userId)
        .orderBy('date', descending: true)
        .get()
        .then((snapshot) {
      final data = snapshot.docs;
      for (var element in data) {
        orders.add(
          element.data(),
        );
      }
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          isLoading = false;
        });
      });
    }).catchError((error) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          isLoading = false;
          isError = true;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: orders.isNotEmpty && isError == false
          ? ListView.builder(
              itemCount: orders.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                List items = orders[i]['items'];
                String description = '';
                for (var element in items) {
                  description +=
                      '${element['quantity']}x ${element['product_name']} ';
                }
                Timestamp timestamp = orders[i]['date'];
                String date = DateFormat.yMMMd().format(timestamp.toDate());
                return OrderTranzCard(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return OrderInfoView(order: orders[i]);
                    }));
                  },
                  date: date,
                  price: orders[i]['price'].toString(),
                  employeeName: 'Riyadh',
                  customerName: orders[i]['customer_info']['customer_name'],
                  desc: description,
                );
              },
            )
          : isLoading
              ? const Center(
                  child: SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: CircularProgressIndicator(
                        color: kMainColor,
                      )),
                )
              : const Center(
                  child: Text(
                    'May be You have\'nt made sale yet. or an error occured. Make sure you already made a sale or try again.',
                    textAlign: TextAlign.center,
                    style: kProductNameStyle,
                  ),
                ),
    );
  }
}
