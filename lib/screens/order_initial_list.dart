import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/order_details.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: kBackgroundColor,
      ),
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('order').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: kMainColor,
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!.docs;
              List orders = [];
              for (var element in data) {
                orders.add(
                  element.data(),
                );
              }

              print('order $orders');
              List<String> columns = [
                'Id',
                'Customer',
                'Items',
                'Price',
                'Date',
                'Payment',
                'Delivery',
                'Action',
              ];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Orders',
                    style: kCategoryNameStylePro,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: Divider(
                  //     color: kScaffoldBackgroundColor,
                  //   ),
                  // ),
                  DataTable(
                    // dataRowHeight: 30.0,
                    showCheckboxColumn: true,
                    decoration: const BoxDecoration(),
                    columnSpacing: 40,
                    columns: List.generate(columns.length, (i) {
                      return DataColumn(
                        label: Text(
                          columns[i],
                          style: const TextStyle(
                            color: kSubMainColor,
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                    rows: List.generate(
                      orders.length,
                      (length) {
                        final String adminId = Hive.box('adminInfo')
                            .get('adminId', defaultValue: 'adminId');
                        List items = orders[length]['items'];
                        List transDesc = List.generate(
                          items.length,
                          (index) {
                            return '${orders[length]['items'][index]['quantity']}x ${orders[length]['items'][index]['product_name']}';
                          },
                          growable: false,
                        );
                        return DataRow(
                          cells: List.generate(
                            columns.length,
                            (i) {
                              List<String> cellData = [
                                orders[length]['orderId'],
                                orders[length]['customerId'],
                                orders[length]['quantity'],
                                orders[length]['price'].toString(),
                                '21-10-2021',
                                orders[length]['payment_status'],
                                orders[length]['delivery_status'],
                                orders[length]['delivery_status'],
                              ];
                              return DataCell(
                                i == 7
                                    ? IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderDetails(
                                                orderId: orders[length]['orderId'],
                                                customerId: orders[length]
                                                    ['customerId'],
                                                price: orders[length]['price'],
                                                role: orders[length]['role'],
                                                transactionData: {
                                                  'price': orders[length]['price'],
                                                  'quantity': orders[length]
                                                      ['quantity'],
                                                  'date': orders[length]['date'],
                                                  'adminId': adminId,
                                                  'items': transDesc,
                                                  'docId': data[length].id,
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_right,
                                          size: 30.0,
                                          color: kMainColor,
                                        ),
                                      )
                                    : Text(cellData[i],
                                        style: i == 5 || i == 6
                                            ? kHeadingStyle
                                            : kProductNameStylePro),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
                ],
              );
            } else {
              return const Text('Oop\'s Error Occured');
            }
          }),
    );
  }
}

class BigScreenOrderDetails extends StatefulWidget {
  const BigScreenOrderDetails({Key? key}) : super(key: key);

  @override
  _BigScreenOrderDetailsState createState() => _BigScreenOrderDetailsState();
}

class _BigScreenOrderDetailsState extends State<BigScreenOrderDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: const Text('Details'),
        titleTextStyle: kProductNameStyle,
        titleSpacing: 1.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    'Order Details',
                    style: kProductNameStyle,
                  ),
                ),
                const SizedBox(
                  width: double.infinity,
                  child: Divider(
                    color: kScaffoldBackgroundColor,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Status',
                          style: kCategoryNameStyle,
                        ),
                        SizedBox(
                          height: 30.0,
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Center(
                            child: DropdownButtonFormField(
                              items: const [],
                              value: '',
                              onChanged: (dynamic value) {},
                              decoration: const InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: kMainColor),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: kMainColor),
                                ),
                                focusColor: kMainColor,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
