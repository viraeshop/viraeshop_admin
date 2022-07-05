import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/desktop_product_cards2.dart';
import 'package:viraeshop_admin/reusable_widgets/form_field.dart';
// import 'package:viraeshop_admin/reusable_widgets/drawer.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  final String orderId, role, customerId;
  final price;
  final Map<String, dynamic> transactionData;
  OrderDetails(
      {required this.orderId,
      required this.role,
      required this.customerId,
      required this.price,
      required this.transactionData});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails>
    with TickerProviderStateMixin {
  GeneralCrud generalCrud = GeneralCrud();
  AdminCrud adminCrud = AdminCrud();
  var _payList = [
    'Advance',
    'Due',
    'Paid'
  ];
  var _deliveryList = ['Pending', 'Delivered'];
  String? pay_stats, delivery_stats;
  bool _shouldload = false;
  TabController? tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.role);
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          iconTheme: IconThemeData(color: kMainColor),
          title: Text(
            'Order Details',
            style: kAppBarTitleTextStyle,
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('order')
                .doc(widget.orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    child: CircularProgressIndicator(
                      color: kMainColor,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                final order = snapshot.data;
                Timestamp dateTime = order!.get('date');
                DateTime date = dateTime.toDate();
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                order.get('price').toString(),
                                style: TextStyle(
                                  fontSize: 50,
                                ),
                              ),
                              trailing: Text('${order.get('quantity')} Items'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.0),
                              child: DropdownButtonFormField(
                                value: pay_stats,
                                decoration: InputDecoration(
                                    // border: OutlineInputBorder(
                                    //     borderRadius: BorderRadius.circular(15)
                                    //     ),
                                    // labelText: "Quantity",
                                    // hintText: "Quantity",
                                    hintStyle:
                                        TextStyle(color: Colors.black87)),
                                hint: Text(
                                    'Payment Status'), // Not necessary for Option 1
                                // value: default_role,
                                onChanged: (change_val) {
                                  print(change_val);
                                  setState(() {
                                    pay_stats = change_val.toString();
                                    // print(selected_role);
                                  });
                                },
                                items: _payList.map((itm) {
                                  return DropdownMenuItem(
                                    child: new Text(itm.toUpperCase()),
                                    value: itm,
                                  );
                                }).toList(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: DropdownButtonFormField(
                                value: delivery_stats,
                                decoration: InputDecoration(
                                    // border: OutlineInputBorder(
                                    //     borderRadius:
                                    //         BorderRadius.circular(
                                    //             15)
                                    //             ),
                                    // labelText: "Quantity",
                                    // hintText: "Quantity",
                                    hintStyle:
                                        TextStyle(color: Colors.black87)),
                                hint: Text(
                                    'Delivery Status'), // Not necessary for Option 1
                                // value: default_role,
                                onChanged: (change_val) {
                                  print(change_val);
                                  setState(() {
                                    delivery_stats = change_val.toString();
                                    // print(selected_role);
                                  });
                                },
                                items: _deliveryList.map((itm) {
                                  return DropdownMenuItem(
                                    child: new Text(itm),
                                    value: itm,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        )),
                      ),
                      // Second
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            TabBar(
                              controller: tabController,
                              indicatorColor: kMainColor,
                              labelColor: kTextColor1,
                              labelStyle: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w300),
                              indicatorPadding:
                                  EdgeInsets.symmetric(horizontal: 21),
                              labelPadding: EdgeInsets.all(6),
                              onTap: (i) {
                                setState(() {
                                  selectedIndex = i;
                                  tabController!.animateTo(i);
                                });
                              },
                              tabs: <Widget>[
                                Text('ITEMS'),
                                Text('DETAILS'),
                                Text('CUSTOMER'),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IndexedStack(
                                children: <Widget>[
                                  orderDet(itemInfo: order.get('items'),
                                  ),
                                  // Tab two
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child:
                                          ListView(shrinkWrap: true, children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Total Quantity:"),
                                            )),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "${order.get('quantity')}",
                                                  style: kProductNameStylePro),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Total Cost:",
                                                  style: kProductNameStylePro),
                                            )),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "${order.get('price').toString()}",
                                                  style: kProductNameStylePro),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Payment Status:",
                                                  style: kProductNameStylePro),
                                            )),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  '${order.get('payment_status')}',
                                                  style: kProductNameStylePro),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Delivery Status:",
                                                  style: kProductNameStylePro),
                                            )),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  '${order.get('delivery_status')}',
                                                  style: kProductNameStylePro),
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Date:",
                                                  style: kProductNameStylePro),
                                            ),),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(date.toString(),
                                                  style: kProductNameStylePro),
                                            )),
                                          ],
                                        )
                                      ]),
                                    ),
                                  ),
                                  // Tab 3
                                  FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection(widget.role)
                                          .doc(widget.customerId)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: Container(
                                              height: 50.0,
                                              width: 50.0,
                                              child: CircularProgressIndicator(
                                                  color: kMainColor,
                                                  ),
                                            ),
                                          );
                                        } else if (snapshot.hasData) {
                                          final data = snapshot.data;
                                          return Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ListTile(
                                                  onTap: () async {
                                                    final phone =
                                                        data!.get('mobile');
                                                    final url = 'tel:$phone';
                                                    if (await canLaunch(url)) {
                                                      await launch(url);
                                                    }
                                                  },
                                                  leading: Icon(
                                                    Icons.call,
                                                    size: 20.0,
                                                    color: kSubMainColor,
                                                  ),
                                                  title: Text(
                                                    'Call ${data!.get('mobile')}',
                                                    style: kProductNameStyle,
                                                  ),
                                                ),
                                                ListTile(
                                                  leading: Icon(
                                                    Icons.place,
                                                    size: 20.0,
                                                    color: kSubMainColor,
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Location',
                                                        style:
                                                            kProductNameStyle,
                                                      ),
                                                      Text(
                                                        '${data.get('address')}',
                                                        style:
                                                            kProductNameStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ListTile(
                                                  leading: Icon(
                                                    Icons.person,
                                                    size: 20.0,
                                                    color: kSubMainColor,
                                                  ),
                                                  title: Text(
                                                    'Call ${data.get('id')}',
                                                    style: kProductNameStyle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: Text('Oops an erro ocured',
                                                style: kProductNameStyle),
                                          );
                                        }
                                      }),
                                ],
                                index: selectedIndex,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Text(
                  'Oops an error occured',
                  style: kProductNameStylePro,
                );
              }
            }),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10),
          child: bottomCard(
              context: context,
              text: 'Update Order',
              onTap: () async {
                if (pay_stats != null && delivery_stats != null) {
                  setState(() {
                    isLoading = true;
                  });
                  await FirebaseFirestore.instance
                      .collection('order')
                      .doc(widget.orderId)
                      .update({
                    'delivery_status': delivery_stats,
                    'payment_status': pay_stats,
                    'seen': true,
                  }).then((value) async {
                    if (pay_stats == 'Paid') {
                      if (widget.role == 'agents') {
                        adminCrud
                            .updateWallet(documentId: widget.customerId, balance: widget.price)
                            .then((value) async {
                          await FirebaseFirestore.instance
                              .collection('transaction')
                              .add(widget.transactionData)
                              .then((value) {
                            setState(() {
                              isLoading = false;
                            });
                            showDialogBox(
                                buildContext: context,
                                msg: 'Updated successfully');
                          });

                          /// Todo: add an exception to handle the issue of trasaction hasn't made successfully
                        }).catchError((error) {
                          setState(() {
                            isLoading = false;
                          });
                          showDialogBox(
                              buildContext: context, msg: 'Insufficient funds');
                        });
                      } else {
                        await FirebaseFirestore.instance
                            .collection('transaction')
                            .doc(widget.orderId)
                            .set(widget.transactionData)
                            .then((value) {
                          setState(() {
                            isLoading = false;
                          });
                          showDialogBox(
                              buildContext: context,
                              msg: 'Updated successfully');
                        });
                      }
                    }
                  }).catchError((value) {
                    setState(() {
                      isLoading = false;
                    });
                    showDialogBox(
                        buildContext: context,
                        msg: 'failed to update. Try again');
                  });
                } else {
                  showDialogBox(
                      buildContext: context, msg: 'Update order status first!');
                }
              }),
        ),
      ),
    );
  }

  // Order details
  orderDet({required List itemInfo}) {
    return Container(
      child: itemInfo.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: itemInfo.length,
              itemBuilder: (BuildContext context, int i) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ListTile(
                      onTap: () {},
                      leading: Image.asset('assets/default.jpg'),
                      // trailing:
                      //     Text('\$${orderList[i]['total_price']}'),
                      title: Text('${itemInfo[i]['product_name']}',
                          style: kProductNameStylePro),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   '${orderList[i]['description']}',
                          //   style: TextStyle(color: Colors.red),
                          // ),
                          Text('Quantity: ${itemInfo[i]['quantity']}',
                              style: kProductNameStylePro),
                          Text('Cost: \$${itemInfo[i]['price']}',
                              style: kProductNameStylePro),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Text('Loading'),
    );
  }
}
