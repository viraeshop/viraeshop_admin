import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/customers/register_customer.dart';

import 'customer_list.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> with TickerProviderStateMixin{
  static List<Tab> tabs = const [
    Tab(
      text: 'All',
    ),
    Tab(text: 'General'),
    Tab(text: 'Agent'),
    Tab(text: 'Architect'),
  ];
  final bool isMakeCustomer = Hive.box('adminInfo').get('isMakeCustomer');
  //late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    //_tabController = TabController(length: tabs.length, vsync: this, initialIndex: 0);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
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
              onPressed: isMakeCustomer ?  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterCustomer(),
                  ),
                );
              } : null,
              icon: const Icon(Icons.add),
              iconSize: 20.0,
              color: kSubMainColor,
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            Customers(
              role: 'all',
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
