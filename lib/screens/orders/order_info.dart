import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/popWidget.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/orders/customer_order_history.dart';
import 'package:viraeshop_admin/screens/orders/order_configs.dart';
import 'package:viraeshop_admin/screens/shops.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../../components/home_screen_components/decision_components.dart';
import '../../configs/configs.dart';
import '../../settings/admin_CRUD.dart';
import 'order_product.dart';

class OrderInfo extends StatefulWidget {
  static const String path = '/order_info';
  final String orderId;
  final String customerName;
  const OrderInfo({required this.orderId, required this.customerName});

  @override
  _OrderInfoState createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  TextEditingController controller = TextEditingController(text: '0');
  AdminCrud adminCrud = AdminCrud();
  bool isLoading = true;
  dynamic order = {};
  final box = Hive.box('orderItems');
  String dateFormat = '';
  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 4, initialIndex: 0, vsync: this);
    adminCrud.getSingleOrder(widget.orderId).then((snapshot) {
      // print(snapshot.data());
      order = snapshot.data() ?? {};
      Timestamp dateTime = snapshot.get('date');
      DateTime date = dateTime.toDate();
      dateFormat = DateFormat.yMMMd().format(date);
      box.putAll({
        'items': snapshot.get('items'),
        'totalPrice': snapshot.get('price'),
        'totalItems': snapshot.get('quantity'),
        'role': snapshot.get('role'),
      }).catchError((error) {
        print(error);
      });
      setState(() {
        isLoading = false;
      });
      print(order);
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  bool invoiceNumberTaken = true;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isCancelOrConfirm =
        order['order_status'] == 'confirm' || order['order_status'] == 'cancel'
            ? true
            : false;
    return ChangeNotifierProvider(
      create: (context) => OrderConfigs(),
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: kMainColor,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: kBackgroundColor,
              appBar: AppBar(
                elevation: 3.0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (Hive.box('orderItems').isNotEmpty) {
                      Hive.box('orderItems').clear();
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.chevronLeft),
                  iconSize: 20.0,
                  color: kSubMainColor,
                ),
                title: Text(
                  widget.customerName,
                  style: kAppBarTitleTextStyle,
                ),
              ),
              body: order.isNotEmpty
                  ? Container(
                      child: ListView(
                        children: [
                          LimitedBox(
                            maxHeight: size.height * 0.92,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                FractionallySizedBox(
                                  //heightFactor: 0.5,
                                  alignment: Alignment.topCenter,
                                  child: ValueListenableBuilder(
                                    valueListenable: box.listenable(),
                                    builder: (context, Box box, childs) {
                                      String totalPrice =
                                          box.get('totalPrice').toString();
                                      String totalItems =
                                          box.get('totalItems').toString();
                                      return Container(
                                        padding: const EdgeInsets.all(15.0),
                                        width: size.width,
                                        color: kBackgroundColor,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              leading: const Text(
                                                'Total Price:',
                                                style: TextStyle(
                                                  color: kBlueColor,
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 20,
                                                  letterSpacing: 1.3,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              trailing: Text(
                                                '$totalPrice৳',
                                                style: const TextStyle(
                                                  color: kNewTextColor,
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 20,
                                                  letterSpacing: 1.3,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.schedule,
                                                size: 20.0,
                                                color: kBlackColor,
                                              ),
                                              trailing: isCancelOrConfirm
                                                  ? const SizedBox()
                                                  : Text(
                                                      '$totalItems QYT ${box.get('items').length} Items',
                                                      style: kTotalSalesStyle,
                                                    ),
                                              title: Consumer<OrderConfigs>(
                                                builder:
                                                    (context, order, childs) =>
                                                        DropdownButton(
                                                  underline: const SizedBox(),
                                                  value: order.orderStats,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'pending',
                                                      child: Text(
                                                        'Pending',
                                                        style: TextStyle(
                                                          color: kYellowColor,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 18,
                                                          letterSpacing: 1.3,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'confirm',
                                                      child: Text(
                                                        'Confirm',
                                                        style: TextStyle(
                                                          color: kNewTextColor,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 18,
                                                          letterSpacing: 1.3,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'cancel',
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: kRedColor,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 18,
                                                          letterSpacing: 1.3,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (value) {
                                                    Provider.of<OrderConfigs>(
                                                            context,
                                                            listen: false)
                                                        .updateOrderStats(
                                                            value.toString());
                                                  },
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: ListTile(
                                                leading: const Icon(
                                                  Icons.local_shipping_outlined,
                                                  size: 20.0,
                                                  color: kBlackColor,
                                                ),
                                                title: Consumer<OrderConfigs>(
                                                  builder: (context, order,
                                                          childs) =>
                                                      DropdownButton(
                                                    underline: const SizedBox(),
                                                    value: order.deliverStats,
                                                    items: const [
                                                      DropdownMenuItem(
                                                        value: 'Pending',
                                                        child: Text(
                                                          'Pending',
                                                          style: TextStyle(
                                                            color: kRedColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 18,
                                                            letterSpacing: 1.3,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'Delivered',
                                                        child: Text(
                                                          'Delivered',
                                                          style: TextStyle(
                                                            color:
                                                                kNewTextColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 18,
                                                            letterSpacing: 1.3,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'Cancel',
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: kRedColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 18,
                                                            letterSpacing: 1.3,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    onChanged: order.orderStats ==
                                                                'pending' ||
                                                            order.orderStats ==
                                                                'cancel'
                                                        ? null
                                                        : (value) {
                                                            Provider.of<OrderConfigs>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .updateDeliveryStats(
                                                                    value
                                                                        .toString());
                                                          },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Consumer<OrderConfigs>(
                                                builder:
                                                    (context, order, childs) =>
                                                        ListTile(
                                                  leading: const Icon(
                                                    Icons.payments,
                                                    size: 20.0,
                                                    color: kBlackColor,
                                                  ),
                                                  isThreeLine: order.payStats ==
                                                          'Advance'
                                                      ? true
                                                      : false,
                                                  subtitle: order.payStats ==
                                                          'Advance'
                                                      ? SizedBox(
                                                          width: 100.0,
                                                          child: TextField(
                                                            controller:
                                                                controller,
                                                            cursorColor:
                                                                kBlackColor,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                kProductNameStylePro,
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  UnderlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color:
                                                                      kYellowColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : null,
                                                  title: DropdownButton(
                                                    underline: const SizedBox(),
                                                    value: order.payStats,
                                                    items: const [
                                                      DropdownMenuItem(
                                                        value: 'Due',
                                                        child: Text(
                                                          'Due',
                                                          style: TextStyle(
                                                            color: kRedColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 18.0,
                                                            letterSpacing: 1.3,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'Advance',
                                                        child: Text(
                                                          'Advance',
                                                          style: TextStyle(
                                                            color: kYellowColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 18,
                                                            letterSpacing: 1.3,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'Paid',
                                                        child: Text(
                                                          'Paid',
                                                          style: TextStyle(
                                                            color:
                                                                kNewTextColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 18,
                                                            letterSpacing: 1.3,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    onChanged: order.orderStats ==
                                                                'pending' ||
                                                            order.orderStats ==
                                                                'cancel'
                                                        ? null
                                                        : (value) {
                                                            Provider.of<OrderConfigs>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .updatePayStats(
                                                                    value
                                                                        .toString());
                                                          },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                FractionallySizedBox(
                                  heightFactor: 0.6,
                                  alignment: Alignment.bottomCenter,
                                  child: ListView(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        color: kStrokeColor,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(
                                                Icons.info,
                                                size: 25.0,
                                                color: kBlueColor,
                                              ),
                                              SizedBox(
                                                width: 6.0,
                                              ),
                                              Text(
                                                'Order Information',
                                                style: TextStyle(
                                                  color: kSubMainColor,
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15,
                                                  letterSpacing: 1.3,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TabBar(
                                        // isScrollable: true,
                                        controller: tabController,
                                        indicatorColor: kMainColor,
                                        labelColor: kMainColor,
                                        indicatorWeight: 3.0,
                                        unselectedLabelColor: Colors.black45,
                                        unselectedLabelStyle: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 15,
                                          letterSpacing: 1.3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        labelStyle: const TextStyle(
                                          color: kMainColor,
                                          fontFamily: 'Montserrat',
                                          fontSize: 15,
                                          letterSpacing: 1.3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        isScrollable: true,
                                        // indicatorPadding:
                                        //     EdgeInsets.symmetric(horizontal: 21),
                                        // labelPadding: EdgeInsets.all(6),
                                        tabs: const [
                                          Tab(text: 'Items'),
                                          Tab(text: 'Details'),
                                          Tab(text: 'Customer Info'),
                                          Tab(text: 'History'),
                                        ],
                                      ),
                                      // Text('data'),
                                      LimitedBox(
                                        maxHeight: size.height * 0.4,
                                        maxWidth: size.width,
                                        child: TabBarView(
                                          controller: tabController,
                                          children: [
                                            OrderProducts(
                                              isCancelOrConfirm:
                                                  isCancelOrConfirm,
                                            ),
                                            ValueListenableBuilder(
                                                valueListenable:
                                                    box.listenable(),
                                                builder:
                                                    (context, Box box, chllds) {
                                                  String price = box
                                                      .get('totalPrice')
                                                      .toString();
                                                  return OrderInformation(
                                                    paymentStatus:
                                                        order['payment_status'],
                                                    deliveryStatus: order[
                                                        'delivery_status'],
                                                    totalPrice: price,
                                                    date: dateFormat,
                                                  );
                                                }),
                                            customerInfo(
                                              info: order['customer_info'],
                                            ),
                                            CustomerOrderHistory(
                                                customerId:
                                                    order['customer_info']
                                                        ['customer_id']),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Consumer<OrderConfigs>(
                                    builder: (context, orders, childs) =>
                                        Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: sendButton(
                                        title: 'Confirm',
                                        onTap: () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          print('start');
                                          final String adminId =
                                              Hive.box('adminInfo').get(
                                                  'adminId',
                                                  defaultValue: 'adminId');
                                          String adminName =
                                              Hive.box('adminInfo').get('name',
                                                  defaultValue: '');
                                          String invoiceNo = generateInvoiceNumber().toString();
                                          while (invoiceNumberTaken) {
                                            final invoice = await NetworkUtility
                                                .getCustomerTransactionInvoicesByID(
                                                    invoiceNo);
                                            if (kDebugMode) {
                                              print(
                                                  'Invoice Taken: ${invoice.exists}');
                                            }
                                            setState(() {
                                              if (!invoice.exists) {
                                                invoiceNumberTaken = false;
                                              } else {
                                                invoiceNo = generateInvoiceNumber().toString();
                                              }
                                            });
                                          }
                                          Map<String, dynamic> transInfo = {
                                            'price': box.get('totalPrice'),
                                            'quantity': box
                                                .get('totalItems')
                                                .toString(),
                                            'date': Timestamp.now(),
                                            'employee_id': adminId,
                                            'employee_name': adminName,
                                            'items': box.get('items'),
                                            'invoice_id': invoiceNo,
                                            'isWithNonInventory': false,
                                            'docId': invoiceNo,
                                            'customer_id':
                                                order['customer_info']
                                                    ['customer_id'],
                                            'customer_role': order['role'],
                                            'paid': orders.payStats == 'Paid'
                                                ? box.get('totalPrice')
                                                : orders.payStats == 'Advance'
                                                    ? num.parse(controller.text)
                                                    : 0,
                                            'due': orders.payStats == 'Due'
                                                ? box.get('totalPrice')
                                                : orders.payStats == 'Advance'
                                                    ? box.get('totalPrice') -
                                                        num.parse(
                                                            controller.text)
                                                    : 0,
                                            'advance':
                                                orders.payStats == 'Advance'
                                                    ? num.parse(controller.text)
                                                    : 0,
                                            'profit': order['profit'],
                                            'discount': 0,
                                            'user_info': {
                                              'name': order['customer_info']
                                                  ['customer_name'],
                                              'email': order['customer_info']
                                                  ['email'],
                                              'address': order['customer_info']
                                                  ['address'],
                                              'mobile': order['customer_info']
                                                  ['mobile'],
                                            },
                                          };
                                          if (kDebugMode) {
                                            print('Map finished');
                                          }
                                          await FirebaseFirestore.instance
                                              .collection('order')
                                              .doc(widget.orderId)
                                              .update({
                                            'delivery_status':
                                                orders.deliverStats,
                                            'payment_status': orders.payStats,
                                            'order_status': orders.orderStats,
                                            'items': box.get('items'),
                                            'price': box.get('totalPrice'),
                                            'quantity': box.get('totalItems'),
                                            'seen': true,
                                            'employee_id': adminId,
                                            'isFromCustomer': false,
                                            'customerToken':
                                                order['customerToken'],
                                          }).then((value) async {
                                            if (kDebugMode) {
                                              print('order updated');
                                            }
                                            if (order['seen'] == false) {
                                              OrderConfigs().updateNewOrders();
                                            }
                                            if (orders.orderStats ==
                                                'confirm') {
                                              if (order['role'] == 'agents') {
                                                if (kDebugMode) {
                                                  print('isAgent');
                                                }
                                                if (orders.payStats == 'Paid' ||
                                                    orders.payStats ==
                                                        'Advance') {
                                                  adminCrud
                                                      .updateWallet(
                                                    documentId:
                                                        order['customer_info']
                                                            ['name'],
                                                    balance:
                                                        box.get('totalPrice'),
                                                  )
                                                      .then((value) async {
                                                    snackBar(
                                                        text:
                                                            'Amount deducted from wallet..',
                                                        context: context);
                                                    snackBar(
                                                        text:
                                                            'Saving transaction data...',
                                                        context: context);
                                                    await adminCrud
                                                        .createTransaction(
                                                            invoiceNo,
                                                            transInfo)
                                                        .then(
                                                      (value) {
                                                        setState(() {
                                                          isLoading = false;
                                                        });
                                                        showDialogBox(
                                                          buildContext: context,
                                                          msg:
                                                              'Updated successfully',
                                                        );
                                                      },
                                                    ).catchError((error) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      showDialogBox(
                                                          buildContext: context,
                                                          msg:
                                                              'error occured. Try again...');
                                                    });
                                                  }).catchError((error) {
                                                    FirebaseFirestore.instance
                                                        .collection('order')
                                                        .doc(widget.orderId)
                                                        .update({
                                                      'delivery_status':
                                                          'Pending',
                                                      'payment_status':
                                                          'pending',
                                                      'order_status': 'pending',
                                                    }).then((value) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      showDialogBox(
                                                          buildContext: context,
                                                          msg:
                                                              'Insufficient funds');
                                                    });
                                                  });
                                                } else {
                                                  if (kDebugMode) {
                                                    print('making transaction');
                                                  }
                                                  await adminCrud
                                                      .createTransaction(
                                                          invoiceNo, transInfo)
                                                      .then(
                                                    (value) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                      showDialogBox(
                                                        buildContext: context,
                                                        msg:
                                                            'Updated successfully',
                                                      );
                                                    },
                                                  ).catchError((error) {
                                                    if (kDebugMode) {
                                                      print(error);
                                                    }
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    showDialogBox(
                                                        buildContext: context,
                                                        msg:
                                                            'error occured. Try again...');
                                                  });
                                                }
                                              } else {
                                                if (kDebugMode) {
                                                  print('making transaction');
                                                }
                                                await adminCrud
                                                    .createTransaction(
                                                        invoiceNo, transInfo)
                                                    .then(
                                                  (value) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    showDialogBox(
                                                      buildContext: context,
                                                      msg:
                                                          'Updated successfully',
                                                    );
                                                  },
                                                ).catchError((error) {
                                                  if (kDebugMode) {
                                                    print(error);
                                                  }
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                  showDialogBox(
                                                      buildContext: context,
                                                      msg:
                                                          'error occured. Try again...');
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              showDialogBox(
                                                buildContext: context,
                                                msg: 'Updated successfully',
                                              );
                                            }
                                          }).catchError(
                                            (value) {
                                              print(value);
                                              setState(
                                                () {
                                                  isLoading = false;
                                                },
                                              );
                                              showDialogBox(
                                                  buildContext: context,
                                                  msg:
                                                      'failed to update. Try again');
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(
                        '',
                        style: kProductNameStylePro,
                      ),
                    )),
        ),
      ),
    );
  }
}

Widget customerInfo({required Map info}) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(
            Icons.person,
            size: 20.0,
            color: kSubMainColor,
          ),
          title: Text(
            'Customer ${info['customer_name']}',
            style: kProductNameStyle,
          ),
        ),
        ListTile(
          onTap: () async {
            final phone = info['mobile'];
            final url = Uri.parse('tel:$phone');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            }
          },
          leading: const Icon(
            Icons.call,
            size: 20.0,
            color: kSubMainColor,
          ),
          title: Text(
            'Call ${info['mobile']}',
            style: kProductNameStyle,
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.place,
            size: 20.0,
            color: kSubMainColor,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location',
                style: kProductNameStyle,
              ),
              Text(
                '${info['address']}',
                style: kProductNameStyle,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class OrderProducts extends StatelessWidget {
  final bool isCancelOrConfirm;
  const OrderProducts({required this.isCancelOrConfirm});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('orderItems').listenable(),
      builder: (context, Box box, childs) {
        List items =
            isCancelOrConfirm ? [] : box.get('items', defaultValue: []);
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                items.length,
                (index) {
                  return OrderProduct(
                    onLongPress: () {
                      final List items = Hive.box(productsBox).get(productsKey);
                      final Map item = items.firstWhere((element) =>
                          element['product_id'] == items[index]['product_id']);
                      num currentPrice = getCurrentPrice(item, box.get('role'));
                      Tuple3<num, num, bool> discountData = computeDiscountData(
                          item, box.get('role'), currentPrice);
                      showDialog<void>(
                          context: context,
                          builder: (context) {
                            return PopWidget(
                              image: item['image'],
                              productCode: item['productId'],
                              productName: item['name'],
                              price: currentPrice.toString(),
                              description: item['description'],
                              category: item['category'],
                              quantity: item['quantity'].toString(),
                              info: item,
                              routeName: HomeScreen.path,
                              isDiscount: discountData.item3,
                              discountPrice: discountData.item1,
                              sellBy: item['sell_by'],
                            );
                          });
                    },
                    product: items[index],
                    index: index,
                    onPress: () {
                      num price = box.get('totalPrice'),
                          quantity = box.get('totalItems');
                      price -= items[index]['product_price'];
                      quantity -= items[index]['quantity'];
                      items.removeAt(index);
                      box.putAll({
                        'items': items,
                        'totalPrice': price,
                        'totalItems': quantity,
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class OrderInformation extends StatelessWidget {
  final String totalPrice, paymentStatus, deliveryStatus, date;
  const OrderInformation(
      {required this.paymentStatus,
      required this.date,
      required this.deliveryStatus,
      required this.totalPrice});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.payments,
            color: kSubMainColor,
            size: 20.0,
          ),
          title: const Text(
            'Total Price',
            style: kProductNameStyle,
          ),
          trailing: Text(
            '$totalPrice৳',
            style: kTotalTextStyle,
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.payment,
            color: kSubMainColor,
            size: 20.0,
          ),
          title: const Text(
            'Payment Status',
            style: kProductNameStyle,
          ),
          trailing: Text(
            paymentStatus,
            style: kTotalTextStyle,
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.local_shipping_outlined,
            color: kSubMainColor,
            size: 20.0,
          ),
          title: const Text(
            'Delivery Status',
            style: kProductNameStyle,
          ),
          trailing: Text(
            deliveryStatus,
            style: kTotalTextStyle,
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.event_outlined,
            color: kSubMainColor,
            size: 20.0,
          ),
          title: const Text(
            'Date',
            style: kProductNameStyle,
          ),
          trailing: Text(
            date,
            style: kTotalTextStyle,
          ),
        ),
      ],
    );
  }
}
