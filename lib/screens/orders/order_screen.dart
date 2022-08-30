import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/notification_ticker.dart';
import 'package:viraeshop_admin/screens/orders/order_configs.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'order_info.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);
  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  GeneralCrud generalCrud = GeneralCrud();
  List order = [];
  bool isLoaded = false;
  int seenGen = 0, seenAgent = 0, seenArc = 0;
  String statusMessage = 'Fetching orders please wait...',
      orderStatusValue = 'Pending';

  @override
  void initState() {
    // TODO: implement initState
    generalCrud.getOrder().then((snapshot) {
      final data = snapshot.docs;

      for (var element in data) {
          order.add(element.data());
          if (element.get('seen') == false &&
              element.get('role') == 'general') {
            seenGen += 1;
          } else if (element.get('seen') == false &&
              element.get('role') == 'agents') {
            seenAgent += 1;
          } else if (element.get('seen') == false &&
              element.get('role') == 'architect') {
            seenArc += 1;
          }
        }
      List orders = order.where(
        (element) {
          if (orderStatusValue == 'Pending') {
            return element['order_status'] == 'pending';
          } else if (orderStatusValue == 'Confirmed') {
            return element['order_status'] == 'confirm';
          } else {
            return element['order_status'] == 'cancel';
          }
        },
      ).toList();
      Provider.of<OrderConfigs>(context, listen: false).updateOrders(orders);
      setState(() {
        isLoaded = true;
      });
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      setState(() {
        statusMessage = 'Failed to fetch orders';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          iconTheme: const IconThemeData(color: kMainColor),
          title: const Text(
            'Orders',
            style: kAppBarTitleTextStyle,
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                // text: 'General',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('General'),
                    const SizedBox(
                      width: 5.0,
                    ),
                    seenGen == 0
                        ? const SizedBox()
                        : NotificationTicker(
                            value: seenGen.toString(),
                          ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Agents'),
                    const SizedBox(
                      width: 5.0,
                    ),
                    seenAgent == 0
                        ? const SizedBox()
                        : NotificationTicker(
                            value: seenAgent.toString(),
                          ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Architect'),
                    const SizedBox(
                      width: 5.0,
                    ),
                    seenArc == 0
                        ? const SizedBox()
                        : NotificationTicker(
                            value: seenArc.toString(),
                          ),
                  ],
                ),
              ),
            ],
            indicatorColor: kMainColor,
            labelColor: kMainColor,
            unselectedLabelColor: kSubMainColor,
            labelStyle: const TextStyle(
              color: kMainColor,
              fontSize: 15.0,
              letterSpacing: 1.3,
              fontFamily: 'Montserrat',
            ),
            unselectedLabelStyle: kProductNameStylePro,
          ),
          actions: [
            DropdownButton<String>(
              underline: null,
                items: const [
                  DropdownMenuItem(
                    value: 'Pending',
                    child: Text(
                      'Pending',
                      style: kProductNameStylePro,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Confirmed',
                    child: Text(
                      'Confirmed',
                      style: kProductNameStylePro,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Canceled',
                    child: Text(
                      'Canceled',
                      style: kProductNameStylePro,
                    ),
                  ),
                ],
                value: orderStatusValue,
                onChanged: (value) {
                  setState(() {
                    orderStatusValue = value!;
                  });
                  List orders = order.where(
                    (element) {
                      if (orderStatusValue == 'Pending') {
                        return element['order_status'] == 'pending';
                      } else if (orderStatusValue == 'Confirmed') {
                        return element['order_status'] == 'confirm';
                      } else {
                        return element['order_status'] == 'cancel';
                      }
                    },
                  ).toList();
                  Provider.of<OrderConfigs>(context, listen: false)
                      .updateOrders(orders);
                }),
          ],
        ),
        body: isLoaded
            ? const TabBarView(
                children: [
                  Order(role: 'general'),
                  Order(
                    role: 'agents',
                  ),
                  Order(role: 'architect'),
                ],
              )
            : Center(
                child: Text(
                  statusMessage,
                  style: kProductNameStylePro,
                ),
              ),
      ),
    );
  }
}

class Order extends StatefulWidget {
  final String role;
  const Order({Key? key, required this.role}) : super(key: key);
  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> {
  List orders = [];
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderConfigs>(
      builder: (context, order, widgets) {
        orders = order.orders.where((element) {
          return element['role'] == widget.role;
        }).toList();
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (BuildContext context, int i) {
            Timestamp dateTime = orders[i]['date'];
            DateTime dates = dateTime.toDate();
            String date = DateFormat.yMMMd().format(dates);
            return Card(
              color:
                  orders[i]['seen'] == true ? kBackgroundColor : kStrokeColor,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderInfo(
                          orderId: orders[i]['orderId'],
                          customerName: orders[i]['customer_info']['customer_name'],
                        ),
                      ),
                    );
                  },
                  // leading: Text(
                  //   '${i + 1}',
                  //   style: TextStyle(
                  //     color: kSubMainColor,
                  //     fontFamily: 'Montserrat',
                  //     fontSize: 20,
                  //     fontWeight: orders[i]['seen'] == false
                  //         ? FontWeight.bold
                  //         : FontWeight.normal,
                  //     letterSpacing: 1.3,
                  //   ),
                  // ),
                  title: ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: kSubMainColor,
                      size: 25.0,
                    ),
                    title: Text(
                      '${orders[i]['customer_info']['customer_name']}',
                      style: TextStyle(
                        color: kSubMainColor,
                        fontFamily: 'Montserrat',
                        fontSize: 17,
                        fontWeight: orders[i]['seen'] == false
                            ? FontWeight.bold
                            : FontWeight.normal,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                  trailing: orders[i]['seen'] == false
                      ? const Text(
                          'New',
                          style: kProductNameStyle,
                        )
                      : const SizedBox(),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.event,
                          color: kBlueColor,
                          size: 25.0,
                        ),
                        title: Text(
                          date,
                          style: kCategoryNameStyle,
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.inventory_2_outlined,
                          color: kSubMainColor,
                          size: 25.0,
                        ),
                        title: Text(
                            '${orders[i]['quantity'].toString()} Products AT ${orders[i]['price'].toString()}',
                            style: kCategoryNameStyle),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.payments,
                          color: kNewTextColor,
                          size: 25.0,
                        ),
                        title: Text(
                          'Payment: ${orders[i]['payment_status']}',
                          style: TextStyle(
                            color: orders[i]['payment_status'] == 'Paid'
                                ? kNewTextColor
                                : orders[i]['payment_status'] == 'Due'
                                    ? kRedColor
                                    : kYellowColor,
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.local_shipping_outlined,
                          size: 25.0,
                          color: kBlackColor,
                        ),
                        title: Text(
                          'Delivery: ${orders[i]['delivery_status']}',
                          style: TextStyle(
                            color: orders[i]['delivery_status'] == 'Delivered'
                                ? kNewTextColor
                                : orders[i]['delivery_status'] == 'Cancel'
                                    ? kRedColor
                                    : kYellowColor,
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
