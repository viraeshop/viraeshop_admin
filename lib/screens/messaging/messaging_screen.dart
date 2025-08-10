import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/customers/register_customer.dart';
import 'package:viraeshop_admin/screens/messaging/all_notifications_page.dart';
import 'package:viraeshop_admin/screens/messaging/role_schedule_page.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({Key? key}) : super(key: key);

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen>
    with TickerProviderStateMixin {
  static List<Tab> tabs = const [
    Tab(
      text: 'All',
    ),
    Tab(text: 'General'),
    Tab(text: 'Architect'),
    Tab(text: 'Agent'),
  ];
  final bool isMakeCustomer = Hive.box('adminInfo').get('isMakeCustomer');
  bool isLoading = false;
  //late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    //_tabController = TabController(length: tabs.length, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: DefaultTabController(
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
              'Messaging',
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
          ),
          body: TabBarView(
            children: [
              AllNotificationsPage(
                onStart: () {
                  setState(() {
                    isLoading = true;
                  });
                },
                onDone: () {
                  setState(() {
                    isLoading = false;
                  });
                },
              ),
              RoleSchedulePage(
                onStart: () {
                  setState(() {
                    isLoading = true;
                  });
                },
                onDone: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                role: 'general',
              ),
              RoleSchedulePage(
                onStart: () {
                  setState(() {
                    isLoading = true;
                  });
                },
                onDone: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                role: 'architect',
              ),
              RoleSchedulePage(
                onStart: () {
                  setState(() {
                    isLoading = true;
                  });
                },
                onDone: () {
                  setState(() {
                    isLoading = false;
                  });
                },
                role: 'agent',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
