import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/register_customer.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import 'customer_list.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Tab> tabs = const [
    Tab(
      text: 'All',
    ),
    Tab(text: 'General'),
    Tab(text: 'Agent'),
    Tab(text: 'Architect'),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              FontAwesomeIcons.chevronLeft,
              color: kSubMainColor,
            ),
            iconSize: 15.0,
          ),
          title: const Text(
            'Customers',
            style: kProductNameStylePro,
          ),
          centerTitle: true,
          bottom: TabBar(
            tabs: tabs,
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
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterCustomer(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              iconSize: 20.0,
              color: kSubMainColor,
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            Customers(
              role: 'All',
              isSelectCustomer: true,
            ),
            Customers(
              role: 'general',
              isSelectCustomer: true,
            ),
            Customers(
              role: 'agents',
              isSelectCustomer: true,
            ),
            Customers(
              role: 'architect',
              isSelectCustomer: true,
            ),
          ],
        ),
      ),
    );
  }
}
