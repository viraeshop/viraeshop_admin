import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/orders/order_info_view.dart';
import 'package:viraeshop_admin/screens/reciept_screen.dart';

import '../orders/order_tranz_card.dart';

class SalesTab extends StatefulWidget {
  final String userId;
  bool? isAdmin;
  SalesTab({required this.userId, this.isAdmin = false});

  @override
  _SalesTabState createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  List transactions = [];
  bool isLoading = true, isError = false;
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
      data.forEach((element) {
        transactions.add(element.data());
        print('running');
      });
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
      child: transactions.isNotEmpty && isError == false
          ? ListView.builder(
              itemCount: transactions.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                List items = transactions[i]['items'];
                String description = '';
                items.forEach((element) {
                  description +=
                      '${element['quantity']} X ${element['product_name']}, ';
                });
                Timestamp timestamp = transactions[i]['date'];
                String date = DateFormat.yMMMd().format(timestamp.toDate());
                return OrderTranzCard(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ReceiptScreen(data: transactions[i]);
                        }));
                      },
                      date: date,
                      price: transactions[i]['price'].toString(),
                      employeeName: transactions[i]['employee_id'],
                      customerName: transactions[i]['user_info']['name'],
                      desc: description,
                    );
              },
            )
          : isLoading
              ? Center(
                  child: SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: CircularProgressIndicator(
                        color: kMainColor,
                      )),
                )
              : Center(
                  child: Text(
                    'May be You have\'nt made sale yet. or an error occured. Make sure you already made a sale or try again.',
                    textAlign: TextAlign.center,
                    style: kProductNameStyle,
                  ),
                ),
    );
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
      data.forEach((element) {
        orders.add(
          element.data(),
        );
      });
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      print(error);
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
      child: orders.isNotEmpty && isError == false
          ? ListView.builder(
              itemCount: orders.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                List items = orders[i]['items'];
                String description = '';
                items.forEach((element) {
                  description +=
                      '${element['quantity']}x ${element['product_name']} ';
                });
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
              ? Center(
                  child: SizedBox(
                      height: 40.0,
                      width: 40.0,
                      child: CircularProgressIndicator(
                        color: kMainColor,
                      )),
                )
              : Center(
                  child: Text(
                    'May be You have\'nt made sale yet. or an error occured. Make sure you already made a sale or try again.',
                    textAlign: TextAlign.center,
                    style: kProductNameStyle,
                  ),
                ),
    );
  }
}
