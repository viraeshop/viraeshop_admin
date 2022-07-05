import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

import 'order_info.dart';

class OrderInfoView extends StatefulWidget {
  final order;
  OrderInfoView({required this.order});

  @override
  State<OrderInfoView> createState() => _OrderInfoViewState();
}

class _OrderInfoViewState extends State<OrderInfoView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String dateFormat = '';
  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    Timestamp dateTime = widget.order['date'];
    DateTime date = dateTime.toDate();
    dateFormat = DateFormat.yMMMd().format(date);
    super.initState();
  }

  Color color(String status) {
    String newStatus = status.toLowerCase();
    Color color = kYellowColor;
    if (newStatus == 'pending' || newStatus == 'advance') {
      color = kYellowColor;
    } else if (newStatus == 'confirm' ||
        newStatus == 'delivered' ||
        newStatus == 'paid') {
      color = kNewTextColor;
    } else {
      color = kRedColor;
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isCancelOrConfirm = widget.order['order_status'] == 'confirm' ||
            widget.order['order_status'] == 'cancel'
        ? true
        : false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order['customer_info']['customer_name'],
          style: kAppBarTitleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(FontAwesomeIcons.chevronLeft),
          color: kSubMainColor,
          iconSize: 25.0,
        ),
        elevation: 3.0,
      ),
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              //heightFactor: 0.5,
              alignment: Alignment.topCenter,
              child: Container(
                padding: EdgeInsets.all(15.0),
                width: size.width,
                color: kBackgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Text(
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
                        '${widget.order['price'].toString()}৳',
                        style: TextStyle(
                          color: kNewTextColor,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.schedule,
                        size: 20.0,
                        color: kBlackColor,
                      ),
                      trailing: isCancelOrConfirm
                          ? SizedBox()
                          : Text(
                              '${widget.order['quantity'].toString()} QTY ${widget.order['items'].length} Items',
                              style: kTotalSalesStyle,
                            ),
                      title: Text(
                        '${widget.order['order_status']}',
                        style: TextStyle(
                          color: color(widget.order['order_status']),
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.local_shipping_outlined,
                        size: 20.0,
                        color: kBlackColor,
                      ),
                      title: Text(
                        '${widget.order['delivery_status']}',
                        style: TextStyle(
                          color: color(widget.order['delivery_status']),
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.payments,
                        size: 20.0,
                        color: kBlackColor,
                      ),
                      title: Text(
                        '${widget.order['payment_status']}',
                        style: TextStyle(
                          color: color(widget.order['payment_status']),
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FractionallySizedBox(
              heightFactor: 0.6,
              alignment: Alignment.bottomCenter,
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.0),
                    color: kStrokeColor,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                  Container(
                    child: TabBar(
                      // isScrollable: true,
                      controller: tabController,
                      indicatorColor: kMainColor,
                      labelColor: kMainColor,
                      indicatorWeight: 3.0,
                      unselectedLabelColor: Colors.black45,
                      unselectedLabelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                      labelStyle: TextStyle(
                        color: kMainColor,
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                      // isScrollable: true,
                      // indicatorPadding:
                      //     EdgeInsets.symmetric(horizontal: 21),
                      // labelPadding: EdgeInsets.all(6),
                      tabs: [
                        Tab(text: 'Items'),
                        Tab(text: 'Details'),
                        Tab(text: 'Customer Info'),
                      ],
                    ),
                  ),
                  // Text('data'),
                  LimitedBox(
                    maxHeight: size.height * 0.4,
                    maxWidth: size.width,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(
                                widget.order['items'].length,
                                (index) {
                                  return orderProduct(
                                    product: widget.order['items'][index],
                                    isWithButton: false,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        OrderInformation(
                          paymentStatus: widget.order['payment_status'],
                          deliveryStatus: widget.order['delivery_status'],
                          totalPrice: widget.order['price'].toString(),
                          date: dateFormat,
                        ),
                        customerInfo(
                          info: widget.order['customer_info'],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
