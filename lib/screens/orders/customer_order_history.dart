import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/orders/order_tranz_card.dart';
import 'package:viraeshop_admin/screens/reciept_screen.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';


class CustomerOrderHistory extends StatefulWidget {
  final String customerId;
  const CustomerOrderHistory({super.key, required this.customerId});

  @override
  State<CustomerOrderHistory> createState() => _CustomerOrderHistoryState();
}

class _CustomerOrderHistoryState extends State<CustomerOrderHistory>
    with AutomaticKeepAliveClientMixin {
  GeneralCrud generalCrud = GeneralCrud();
  bool isAlive = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<QuerySnapshot>(
          future: generalCrud.getCustomerOrder(widget.customerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              isAlive = true;
              final data = snapshot.data!.docs;
              List orders = [];
              for (var element in data) {
                orders.add(element.data());
              }
              return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, i) {
                    Timestamp timestamp = orders[i]['date'];
                    DateTime dateTime = timestamp.toDate();
                    String date = DateFormat.yMMMd().format(dateTime);
                    List items = orders[i]['items'];
                    String description = '';
                    for (var element in items) {
                      description +=
                          '${element['quantity']}x ${element['product_name']} ';
                    }
                    return OrderTranzCard(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ReceiptScreen(isFromOrder: true, data: orders[i],);
                        }));
                      },
                      date: date,
                      price: orders[i]['price'].toString(),
                      employeeName: orders[i]['employeeName'],
                      customerName: orders[i]['customer_info']['customer_name'],
                      desc: description,
                    );
                  });
            } else {
              isAlive = false;
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sorry please try again...',
                      style: kTableCellStyle,
                    ),
                    // SizedBox(
                    //   height: 10.0,
                    // ),
                    // IconButton(onPressed: (){

                    // }, icon:
                    // )
                  ],
                ),
              );
            }
          }),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
