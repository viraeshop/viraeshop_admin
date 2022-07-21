import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/desktop_orders.dart';
import 'package:viraeshop_admin/reusable_widgets/notification_ticker.dart';
import 'package:viraeshop_admin/reusable_widgets/resusable_tile.dart';
import 'package:viraeshop_admin/reusable_widgets/transaction_details.dart';
import 'package:viraeshop_admin/screens/add_user.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';
import 'package:viraeshop_admin/screens/advert/advert_screen.dart';
import 'package:viraeshop_admin/screens/agent_products.dart';
import 'package:viraeshop_admin/screens/agents_list.dart';
import 'package:viraeshop_admin/screens/allusers.dart';
import 'package:viraeshop_admin/screens/architect_products.dart';
import 'package:viraeshop_admin/screens/architects_list.dart';
import 'package:viraeshop_admin/screens/catalog.dart';
import 'package:viraeshop_admin/screens/category_screen.dart';
import 'package:viraeshop_admin/screens/customers/customer_request.dart';
import 'package:viraeshop_admin/screens/customers_list.dart';
import 'package:viraeshop_admin/screens/expense_history.dart';
import 'package:viraeshop_admin/screens/general_products.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/layout_screen/modal_view.dart';
import 'package:viraeshop_admin/screens/login_page.dart';
import 'package:viraeshop_admin/screens/messages_screen/customers_group.dart';
import 'package:viraeshop_admin/screens/messages_screen/messages.dart';
import 'package:viraeshop_admin/screens/messages_screen/users_screen.dart';
import 'package:viraeshop_admin/screens/new_admin_user.dart';
import 'package:viraeshop_admin/screens/new_expense.dart';
import 'package:viraeshop_admin/screens/non_inventory/search_product_expense.dart';
import 'package:viraeshop_admin/screens/orders/order_screen.dart';
import 'package:viraeshop_admin/screens/new_product_screen.dart';
import 'package:viraeshop_admin/screens/product_expense.dart';
import 'package:viraeshop_admin/screens/products_screen.dart';
import 'package:viraeshop_admin/screens/return_history.dart';
import 'package:viraeshop_admin/screens/return_product.dart';
import 'package:viraeshop_admin/screens/settings_screen.dart';
import 'package:viraeshop_admin/screens/signup_request.dart';
import 'package:viraeshop_admin/screens/transaction_screen.dart';
import 'package:viraeshop_admin/screens/user_list.dart';
import 'package:viraeshop_admin/screens/user_profile.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

import '../screens/about_us_page.dart';
import '../screens/new_non_inventory.dart';

class AppDrawer extends StatefulWidget {
  var info;
  final bool isBigScreen;
  String totalMessages;
  String newOrders;
  AppDrawer({
    Key? key,
    this.info,
    required this.isBigScreen,
    required this.totalMessages,
    required this.newOrders,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late ScrollController _scrollController;
  bool isProduct = true,
      isMakeCustomer = true,
      isTransactions = true,
      isMakeAdmin = true;
  String name = '', email = '';
  String newMessages = '';
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
    newMessages = widget.totalMessages;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: 10,
        color: kSubMainColor,
        child: Scrollbar(
          isAlwaysShown: false,
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
                          if (widget.isBigScreen == true) {
                            Provider.of<Configs>(context, listen: false)
                                .updateWidget(
                              const UserProfile(),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserProfile(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 150.0,
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(30.0)),
                          child: const Center(
                            child: Text(
                              'Admin',
                              style: kDrawerTextStyle2,
                            ),
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
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     ModalWidget(),
                      //   );
                      // } else {
                        Provider.of<AdsProvider>(context, listen: false)
                            .updateDrawerWidget('Tab Widget');
                            Navigator.pop(context);
                      //}
                    },
                  ),
                  ReusableTile(
                    ticker: widget.newOrders != '0'
                        ? NotificationTicker(value: widget.newOrders)
                        : const SizedBox(),
                    icon: FontAwesomeIcons.shoppingBag,
                    title: 'Orders',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     DesktopOrders(),
                      //   );
                      // } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Orders(),
                          ),
                        );
                      //}
                    },
                  ),
                  ReusableTile(
                    icon: FontAwesomeIcons.cube,
                    title: 'Products',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     Products(),
                      //   );
                      // } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Products(),
                          ),
                        );
                      //}
                    },
                  ),
                  ReusableTile(
                    icon: Icons.grid_view,
                    title: 'Category',
                    onTap: () {
                      // if (widget.isBigScreen == true) {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) {
                      //         return CategoryScreen();
                      //       },
                      //     ),
                      //   );
                      // } else {
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
                    onTap: isTransactions == false
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
                    title: 'General',
                    onTap: isMakeCustomer == false
                        ? null
                        : () {
                            // if (widget.isBigScreen == true) {
                            //   Provider.of<Configs>(context, listen: false)
                            //       .updateWidget(
                            //     CustomersPage(),
                            //   );
                            // } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CustomersPage(),
                                ),
                              );
                           // }
                          },
                  ),
                  ReusableTile(
                    onTap: isMakeCustomer == false
                        ? null
                        : () {
                        //     if (widget.isBigScreen == true) {
                        //       Provider.of<Configs>(context, listen: false)
                        //           .updateWidget(
                        //         AgentsPage(),
                        //       );
                        //     } else {
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
                    onTap: isMakeCustomer == false
                        ? null
                        : () {
                            // if (widget.isBigScreen == true) {
                            //   Provider.of<Configs>(context, listen: false)
                            //       .updateWidget(
                            //     ArchitectsPage(),
                            //   );
                            // } else {
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
                    onTap: isMakeCustomer == false
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
                    ticker: newMessages != '0'
                        ? NotificationTicker(value: newMessages)
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
                            builder: (context) => UsersMessagesScreen(),
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
                    icon: FontAwesomeIcons.ad,
                    title: 'Advertisements',
                  ),
                  ReusableTile(
                    onTap: () {
                     // if (widget.isBigScreen == true) {
                      //   Provider.of<Configs>(context, listen: false)
                      //       .updateWidget(
                      //     ReturnHistory(),
                      //   );
                      // } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReturnHistory(),
                          ),
                        );
                      //}
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
                            builder: (context) => NewNonInventoryProduct(),
                          ),
                        );
                      //}
                    },
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
             const  SizedBox(
               width: double.infinity,
                child: Divider(
                  color: Colors.black38,
                ),
              ),
              ReusableTile(
                title: 'About Us & Privacy',
                icon: Icons.info,
                onTap: (){
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context)=> AboutUsPage()),
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
