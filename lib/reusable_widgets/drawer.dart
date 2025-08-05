import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/notification_ticker.dart';
import 'package:viraeshop_admin/screens/advert/home_button_advert.dart';
import 'package:viraeshop_admin/screens/general_provider.dart';
import 'package:viraeshop_admin/screens/orders/processing.dart';
import 'package:viraeshop_admin/reusable_widgets/resusable_tile.dart';
import 'package:viraeshop_admin/screens/customers/all_customers.dart';
import 'package:viraeshop_admin/screens/customers/general_customers.dart';
import 'package:viraeshop_admin/screens/admins/edit_employee.dart';
import 'package:viraeshop_admin/screens/orders/orderRoutineReport.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_admin/screens/supplier/suppliers_list.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';
import 'package:viraeshop_admin/screens/customers/agents_list.dart';
import 'package:viraeshop_admin/screens/admins/allusers.dart';
import 'package:viraeshop_admin/screens/customers/architects_list.dart';
import 'package:viraeshop_admin/screens/customers/customer_request.dart';
import 'package:viraeshop_admin/screens/due/due_screen.dart';
import 'package:viraeshop_admin/screens/expense_history.dart';
import 'package:viraeshop_admin/screens/login_page.dart';
import 'package:viraeshop_admin/screens/messages_screen/users_screen.dart';
import 'package:viraeshop_admin/screens/new_expense.dart';
import 'package:viraeshop_admin/screens/return_history.dart';
import 'package:viraeshop_admin/screens/return_product.dart';
import 'package:viraeshop_admin/screens/settings_screen.dart';
import 'package:viraeshop_admin/screens/supplier_pay.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

import '../screens/about_us_page.dart';
import '../screens/new_non_inventory.dart';
import '../screens/orders/delivery_screen.dart';
import '../screens/products/category_screen.dart';

class AppDrawer extends StatefulWidget {
  var info;
  final bool isBigScreen;
  String totalMessages;
  String newOrders;
  String processingOrdersCount;
  String receivedOrdersCount;
  String assignedProcessingOrderCount;
  String customerAccountUpgradeRequests;
  AppDrawer({super.key,
    this.info,
    required this.isBigScreen,
    required this.totalMessages,
    required this.newOrders,
    required this.receivedOrdersCount,
    required this.processingOrdersCount,
    required this.assignedProcessingOrderCount,
    required this.customerAccountUpgradeRequests
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late ScrollController _scrollController;
  bool isProduct = true,
      isMakeCustomer = true,
      isTransactions = true,
      isMakeAdmin = true,
      isManageDue = true;
  String name = '', email = '';
  // String newMessages = '';
  // String newOrders = '';
  @override
  void initState() {
    // TODO: implement initState
    _scrollController = ScrollController();
    name = Hive.box('adminInfo').get('name');
    email = Hive.box('adminInfo').get('email');
    isProduct = Hive.box('adminInfo').get('isProducts');
    isMakeCustomer = Hive.box('adminInfo').get('isMakeCustomer');
    isMakeAdmin = Hive.box('adminInfo').get('isMakeAdmin');
    isTransactions = Hive.box('adminInfo').get('isTransactions');
    isManageDue = Hive.box('adminInfo').get('isManageDue');
    // newMessages = widget.totalMessages;
    // newOrders = widget.newOrders;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.receivedOrdersCount);
    return Drawer(
      child: Container(
        width: 10,
        color: kSubMainColor,
        child: Scrollbar(
          thumbVisibility: false,
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 60.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              border: Border.all(width: 5.0, color: kMainColor),
                              color: kBackgroundColor),
                        ),
                        const SizedBox(
                          width: 7.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vira Eshop',
                              style: kDrawerTextStyle1,
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              name,
                              style: kDrawerTextStyle2,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Provider.of<OrderProvider>(context, listen: false)
                              .updateOrderStage(OrderStages.admin);
                          final adminInfo = Hive.box('adminInfo')
                              .toMap()
                              .cast<String, dynamic>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return EditUserScreen(
                                  selfAdmin: true,
                                  adminInfo: adminInfo,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: 150.0,
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(30.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'Admin',
                                style: kDrawerTextStyle2,
                              ),
                              if (widget.assignedProcessingOrderCount != '0' &&
                                  widget.assignedProcessingOrderCount.isNotEmpty)
                                NotificationTicker(
                                  value: widget.assignedProcessingOrderCount,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ReusableTile(
                    icon: Icons.dashboard_outlined,
                    // selected: true,
                    title: 'Home',
                    onTap: () {
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateDrawerWidget('Tab Widget');
                      Navigator.pop(context);
                    },
                  ),
                  Consumer<GeneralProvider>(builder: (context, item, any) {
                    return ReusableTile(
                      ticker: item.newOrders != '0'
                          ? NotificationTicker(value: item.newOrders)
                          : const SizedBox(),
                      icon: FontAwesomeIcons.shoppingBag,
                      title: 'Orders',
                      onTap: () {
                        Provider.of<OrderProvider>(context, listen: false)
                            .updateOrderStage(OrderStages.order);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderRoutineReport(
                              title: 'Orders',
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  ReusableTile(
                    ticker: widget.processingOrdersCount != '0' &&
                            widget.processingOrdersCount.isNotEmpty
                        ? NotificationTicker(
                            value: widget.processingOrdersCount)
                        : const SizedBox(),
                    icon: FontAwesomeIcons.shoppingBag,
                    title: 'Processing',
                    onTap: () {
                      Provider.of<OrderProvider>(context, listen: false)
                          .updateOrderStage(OrderStages.processing);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProcessingScreen(),
                        ),
                      );
                    },
                  ),
                  ReusableTile(
                    ticker: widget.receivedOrdersCount != '0' &&
                            widget.receivedOrdersCount.isNotEmpty
                        ? NotificationTicker(value: widget.receivedOrdersCount)
                        : const SizedBox(),
                    icon: FontAwesomeIcons.bagShopping,
                    title: 'Delivery',
                    onTap: () {
                      Provider.of<OrderProvider>(context, listen: false)
                          .updateOrderStage(OrderStages.receiving);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryScreen(),
                        ),
                      );
                    },
                  ),
                  // ReusableTile(
                  //   icon: FontAwesomeIcons.cube,
                  //   title: 'Products',
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const Products(),
                  //       ),
                  //     );
                  //     //}
                  //   },
                  // ),
                  ReusableTile(
                    icon: Icons.grid_view,
                    title: 'Category',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryScreen(),
                        ),
                      );
                      // }
                    },
                  ),
                  ReusableTile(
                    icon: Icons.grid_view,
                    title: 'Transactions',
                    onTap: !isTransactions
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const TransactionDetails();
                                },
                              ),
                            );
                          },
                  ),
                  const ReusableTile(
                    icon: FontAwesomeIcons.users,
                    title: 'Customers',
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'All Customers',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllCustomers(),
                        ),
                      );
                    },
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'General',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GeneralCustomers(),
                        ),
                      );
                    },
                  ),
                  ReusableTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AgentsPage(),
                        ),
                      );
                      //    }
                    },
                    padding: true,
                    title: 'Agent',
                  ),
                  ReusableTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArchitectsPage(),
                        ),
                      );
                      //}
                    },
                    padding: true,
                    title: 'Architects',
                  ),
                  ReusableTile(
                    ticker: widget.customerAccountUpgradeRequests != '0' &&
                            widget.customerAccountUpgradeRequests.isNotEmpty
                        ? NotificationTicker(value: widget.customerAccountUpgradeRequests)
                        : const SizedBox(),
                    onTap: !isMakeCustomer
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerRequests(),
                              ),
                            ),
                    padding: true,
                    title: 'Customer Requests',
                  ),
                  ReusableTile(
                    ticker: widget.totalMessages != '0' &&
                            widget.totalMessages.isNotEmpty
                        ? NotificationTicker(value: widget.totalMessages)
                        : const SizedBox(),
                    icon: Icons.message,
                    title: 'Messages',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     UsersMessagesScreen(),
                      //   );
                      // } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UsersMessagesScreen(),
                        ),
                      );
                      //}
                    },
                  ),
                  ReusableTile(
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     AdvertScreen(),
                      //   );
                      // } else {
                      Provider.of<AdsProvider>(context, listen: false)
                          .updateDrawerWidget('Advert');
                      Navigator.pop(context);
                      //}
                    },
                    icon: FontAwesomeIcons.rectangleAd,
                    title: 'Advertisements',
                  ),
                  ReusableTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeButtonAdvert()
                        ),
                      );
                    },
                    icon: Icons.inventory,
                    title: 'Home Adverts',
                  ),
                  ReusableTile(
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReturnHistory(),
                        ),
                      );
                    },
                    icon: Icons.inventory,
                    title: 'Returns',
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'Add Return',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReturnProduct(),
                      ),
                    ),
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'Return History',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReturnHistory(),
                      ),
                    ),
                  ),
                  const ReusableTile(
                    icon: Icons.bar_chart,
                    title: 'Expenses',
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'Add Expense',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     NewExpense(),
                      //   );
                      // } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewExpense(),
                        ),
                      );
                      //}
                    },
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'Expense History',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     ExpenseHistory(),
                      //   );
                      // } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenseHistory(),
                        ),
                      );
                      //}
                    },
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'Product Expense',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     NewNonInventoryProduct(),
                      //   );
                      // } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewNonInventoryProduct(),
                        ),
                      );
                      //}
                    },
                  ),
                  ReusableTile(
                    padding: true,
                    title: 'Supplier Pay',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     NewNonInventoryProduct(),
                      //   );
                      // } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupplierPay(),
                        ),
                      );
                      //}
                    },
                  ),
                  ReusableTile(
                    icon: Icons.attach_money,
                    title: 'Due',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DueScreen(),
                      ),
                    ),
                  ),
                  ReusableTile(
                      icon: FontAwesomeIcons.userCog,
                      title: 'Users',
                      onTap: isMakeAdmin == false
                          ? null
                          : () {
                              // if (widget.isBigScreen == true) {
                              //   Provider.of<Configs>(context, listen: false)
                              //       .updateWidget(
                              //     AllUserScreen(),
                              //   );
                              // } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllUserScreen(),
                                ),
                              );
                              //}
                            }),
                  ReusableTile(
                      icon: FontAwesomeIcons.userCog,
                      title: 'Suppliers',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupplierList(),
                          ),
                        );
                      }),
                  ReusableTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     SettingsScreen(),
                      //   );
                      // } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                      //}
                    },
                  ),
                  ReusableTile(
                    onTap: () {
                      FirebaseAuth.instance.signOut().then(
                        (value) {
                          removeLogin().whenComplete(
                            () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, LoginPage.path, (route) => false);
                            },
                          );
                        },
                      ).catchError(
                        (error) {
                          print(error);
                          showDialogBox(
                              buildContext: context,
                              msg: 'Unable to Logout please try again');
                        },
                      );
                    },
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                  ),
                ],
              ),
              const SizedBox(
                width: double.infinity,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              ReusableTile(
                title: 'About Us & Privacy',
                icon: Icons.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
