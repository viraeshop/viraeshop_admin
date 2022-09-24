import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'customer_list.dart';

class GeneralCustomers extends StatefulWidget {
  const GeneralCustomers({Key? key}) : super(key: key);
  @override
  _GeneralCustomersState createState() => _GeneralCustomersState();
}

class _GeneralCustomersState extends State<GeneralCustomers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'General Customers',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: const Customers(
        role: 'general',
      ),
    );
  }
}