import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/order_initial_list.dart';

import 'configs.dart';

class DesktopOrders extends StatelessWidget {
  const DesktopOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: Text('Orders'),
        titleTextStyle: kProductNameStyle,
        titleSpacing: 1.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerContainer(heading: 'Orders'),
            SizedBox(
              height: 20.0,
            ),
            OrderList(),
          ],
        ),
      ),
    );
  }
}
