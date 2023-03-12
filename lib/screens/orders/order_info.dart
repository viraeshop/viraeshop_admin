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
import 'package:viraeshop/orders/barrel.dart';
import 'package:viraeshop/transactions/barrel.dart';

import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/popWidget.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/orders/customer_order_history.dart';
import 'package:viraeshop_admin/screens/orders/order_configs.dart';
import 'package:viraeshop_admin/screens/supplier/shops.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_api/models/customers/customers.dart';
import 'package:viraeshop_api/models/transactions/transactions.dart';
import 'package:viraeshop_api/utils/utils.dart';
import 'package:viraeshop_api/models/items/item_list.dart';

import '../../components/home_screen_components/decision_components.dart';
import '../../configs/configs.dart';
import '../../settings/admin_CRUD.dart';
import '../customers/preferences.dart';
import 'order_product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/orders/orders.dart';

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
  bool isLoading = false;
  late Orders order;
  final box = Hive.box('orderItems');
  String dateFormat = '';
  String adminId = Hive.box('adminInfo').get('adminId', defaultValue: '');
  String adminName = Hive.box('adminInfo').get('name', defaultValue: '');
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 4, initialIndex: 0, vsync: this);
    // adminCrud.getSingleOrder(widget.orderId).then((snapshot) {
    //   // print(snapshot.data());
    //   print(order);
    // }).catchError((error) {
    //   setState(() {
    //     isLoading = false;
    //   });
    // });
    super.initState();
  }

  String orderStats = '';
  String payStats = '';
  bool orderUpdated = false;
  Map<String, dynamic> transInfo = {};
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<OrdersBloc, OrderState>(
      listener: (context, state) {
      final transacBloc = BlocProvider.of<TransactionsBloc>(context);
      if (state is RequestFinishedOrderState) {
        setState(() {
          orderUpdated = true;
        });
        if (orderStats == 'confirm') {
          if (order.role == 'agents') {
            if (payStats == 'Paid' || payStats == 'Advance') {
              ///TODO: Add wallet deductions here...
            } else {
              transacBloc.add(AddTransactionEvent(
                  token: jWTToken,
                  transactionModel: transInfo));
            }
          } else {
            transacBloc.add(AddTransactionEvent(
                token: jWTToken,
                transactionModel: transInfo));
          }
        } else {
          setState(() {
            isLoading = false;
          });
          toast(
            context: context,
            title: 'Updated successfully',
          );
        }
      }else if (state is OnErrorOrderState) {
        setState(() {
          isLoading = false;
        });
        snackBar(text: state.message, context: context, color: kRedColor, duration: 30);
      }
    }, buildWhen: (prevState, currState) {
      if (currState is FetchedOrderState) {
        return true;
      } else if (prevState is LoadingOrderState &&
          currState is OnErrorOrderState) {
        return true;
      } else {
        return false;
      }
    }, builder: (context, state) {
      if (state is OnErrorOrderState) {
        return Material(
          child: Center(
            child: Text(
              state.message,
              style: kProductNameStylePro,
            ),
          ),
        );
      } else if (state is FetchedOrderState) {
        final orderBloc = BlocProvider.of<OrdersBloc>(context);
        order = state.orderModel;
        bool isCancelOrConfirm =
            order.orderStatus == 'confirm' || order.orderStatus == 'cancel'
                ? true
                : false;
        Timestamp dateTime = dateFromJson(order.createdAt);
        DateTime date = dateTime.toDate();
        dateFormat = DateFormat.yMMMd().format(date);
        List orderItems = [];
        for (var item in order.items){
          orderItems.add(item.toJson());
        }
        box.putAll({
          'items': orderItems,
          'totalPrice': order.price,
          'totalItems': order.quantity,
          'role': order.role,
        });
        setState(() {
          isLoading = false;
        });
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
                body: BlocListener<TransactionsBloc, TransactionState>(
                  listener: (context, state) {
                    if (state is RequestFinishedTransactionState) {
                      setState(() {
                        isLoading = false;
                      });
                      toast(
                        context: context,
                        title: 'Updated successfully',
                      );
                    } else if (state is OnErrorTransactionState) {
                      setState(() {
                        isLoading = false;
                      });
                      snackBar(
                        context: context,
                        text: state.message,
                        color: kRedColor,
                        duration: 30,
                      );
                    }
                  },
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
                                            builder: (context, order, childs) =>
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
                                                      fontFamily: 'Montserrat',
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
                                                      fontFamily: 'Montserrat',
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
                                                      fontFamily: 'Montserrat',
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
                                        ListTile(
                                          leading: const Icon(
                                            Icons.local_shipping_outlined,
                                            size: 20.0,
                                            color: kBlackColor,
                                          ),
                                          title: Consumer<OrderConfigs>(
                                            builder: (context, order, childs) =>
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
                                                      fontFamily: 'Montserrat',
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
                                                      color: kNewTextColor,
                                                      fontFamily: 'Montserrat',
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
                                                      fontFamily: 'Montserrat',
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
                                                              listen: false)
                                                          .updateDeliveryStats(
                                                              value.toString());
                                                    },
                                            ),
                                          ),
                                        ),
                                        Consumer<OrderConfigs>(
                                          builder: (context, order, childs) =>
                                              ListTile(
                                            leading: const Icon(
                                              Icons.payments,
                                              size: 20.0,
                                              color: kBlackColor,
                                            ),
                                            isThreeLine:
                                                order.payStats == 'Advance'
                                                    ? true
                                                    : false,
                                            subtitle: order.payStats ==
                                                    'Advance'
                                                ? SizedBox(
                                                    width: 100.0,
                                                    child: TextField(
                                                      controller: controller,
                                                      cursorColor: kBlackColor,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          kProductNameStylePro,
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                            color: kYellowColor,
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
                                                      fontFamily: 'Montserrat',
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
                                                      fontFamily: 'Montserrat',
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
                                                      color: kNewTextColor,
                                                      fontFamily: 'Montserrat',
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
                                                              listen: false)
                                                          .updatePayStats(
                                                              value.toString());
                                                    },
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
                                          isCancelOrConfirm: isCancelOrConfirm,
                                        ),
                                        ValueListenableBuilder(
                                            valueListenable: box.listenable(),
                                            builder:
                                                (context, Box box, chllds) {
                                              String price = box
                                                  .get('totalPrice')
                                                  .toString();
                                              return OrderInformation(
                                                paymentStatus:
                                                    order.paymentStatus,
                                                deliveryStatus:
                                                    order.deliveryStatus,
                                                totalPrice: price,
                                                date: dateFormat,
                                              );
                                            }),
                                        customerInfo(
                                          info: order.customerInfo.toJson(),
                                        ),
                                        CustomerOrderHistory(
                                            customerId:
                                                order.customerInfo.customerId),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Consumer<OrderConfigs>(
                                builder: (context, orders, childs) => Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: sendButton(
                                    title: 'Confirm',
                                    onTap: () {
                                      if (!orderUpdated) {
                                        ItemList items = ItemList.fromJson(
                                            {'itemList': box.get('items')});
                                        setState(() {
                                          isLoading = true;
                                          orderStats = orders.orderStats;
                                          payStats = orders.payStats;
                                          transInfo = {
                                            'customerId': order.customerId,
                                            'createdAt':
                                            dateToJson(Timestamp.now()),
                                            'updatedAt':
                                            dateToJson(Timestamp.now()),
                                            'advance':
                                            orders.payStats == 'Advance'
                                                ? num.parse(controller.text)
                                                : 0,
                                            'role': order.role,
                                            'discount': 0,
                                            'due': orders.payStats == 'Due'
                                                ? box.get('totalPrice')
                                                : orders.payStats == 'Advance'
                                                ? box.get('totalPrice') -
                                                num.parse(
                                                    controller.text)
                                                : 0,
                                            'isWithNonInventory': false,
                                            'paid': orders.payStats == 'Paid'
                                                ? box.get('totalPrice')
                                                : orders.payStats == 'Advance'
                                                ? num.parse(controller.text)
                                                : 0,
                                            'price': box.get('totalPrice'),
                                            'profit': order.profit,
                                            'quantity': order.quantity,
                                            'adminId': adminId,
                                            'items': items.itemList,
                                          };
                                        });
                                        Orders orderInfo = Orders(
                                          customerId: order.customerId,
                                          role: order.role,
                                          adminId: adminId,
                                          orderId: order.orderId,
                                          deliveryStatus: order.deliveryStatus,
                                          paymentStatus: order.paymentStatus,
                                          orderStatus: order.orderStatus,
                                          isFromCustomer: order.isFromCustomer,
                                          price: box.get('totalPrice'),
                                          profit: order.profit,
                                          quantity: order.quantity,
                                          seen: order.seen,
                                          token: order.token,
                                          items: items.itemList,
                                          adminInfo: AdminModel(
                                            name: adminName,
                                            adminId: adminId,
                                            isAdmin: false,
                                          ),
                                          customerInfo: CustomerModel(
                                            name: order.customerInfo.name,
                                            email: order.customerInfo.email,
                                            address: order.customerInfo.email,
                                            mobile: order.customerInfo.mobile,
                                            role: order.customerInfo.role,
                                            customerId:
                                                order.customerInfo.customerId,
                                          ),
                                          updatedAt:
                                              dateToJson(Timestamp.now()),
                                          createdAt: order.createdAt,
                                        );
                                        orderBloc.add(UpdateOrderEvent(
                                          token: jWTToken,
                                            orderId: widget.orderId,
                                            orderModel: orderInfo));
                                      }
                                      ///Todo: update order count here..
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
                ),
              ),
            ),
          ),
        );
      }
      return const Material(
        child: Center(
          child: Text(
            'Fetching order please wait...',
            style: kProductNameStylePro,
          ),
        ),
      );
    });
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
            'Customer ${info['customerName']}',
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
                      final Map<String, dynamic> item = items.firstWhere((element) =>
                          element['productId'] == items[index]['productId']);
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
