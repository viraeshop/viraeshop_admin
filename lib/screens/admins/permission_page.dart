import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/admins/password_screen.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}): super(key: key);
  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  Map<String, bool> bools = {
    'isAdmin': false,
    'isInventory': false,
    'isProduct': false,
    'isTransaction': false,
    'isMakeCustomer': false,
    'isMakeAdmin': false,
    'isDeleteCustomer': false,
    'isDeleteEmployee': false,
    'isManageDue': false,
    'isEditCustomer': false,
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            color: kSubMainColor,
          ),
        ),
        title: const Text(
          'New User',
          style: kProductNameStylePro,
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(13.0),
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Column(
                children: [
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Administrator',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isAdmin']!,
                      onChanged: (status) {
                        setState(() {
                          bools['isAdmin'] = status;
                          bools['isInventory'] = status;
                          bools['isProduct'] = status;
                          bools['isTransaction'] = status;
                          bools['isMakeAdmin'] = status;
                          bools['isMakeCustomer'] = status;
                          bools['isDeleteCustomer'] = status;
                          bools['isManageDue'] = status;
                          bools['isDeleteEmployee'] = status;
                          bools['isEditCustomer'] = status;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Create and Edit products',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isProduct']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                              setState(() {
                                bools['isProduct'] = status;
                              });
                            },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Manage Inventory',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isInventory']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                              setState(() {
                                bools['isInventory'] = status;
                              });
                            },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'View Transactions',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isTransaction']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                              setState(() {
                                bools['isTransaction'] = status;
                              });
                            },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Create Customers',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isMakeCustomer']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                              setState(() {
                                bools['isMakeCustomer'] = status;
                              });
                            },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Edit Customers',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isEditCustomer']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                        setState(() {
                          bools['isEditCustomer'] = status;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Create Employee',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isMakeAdmin']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                              setState(() {
                                bools['isMakeAdmin'] = status;
                              });
                            },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Delete Employee',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isDeleteEmployee']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                        setState(() {
                          bools['isDeleteEmployee'] = status;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Delete Customer',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isDeleteCustomer']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                        setState(() {
                          bools['isDeleteCustomer'] = status;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    // leading: Icon(Icons.dark_mode),
                    title: const Text(
                      'Manage Due',
                      style: kProductNameStyle,
                    ),
                    onTap: () {
                      // Provider.of<Configs>(context, listen: false).toggleDarkMode();
                    },
                    trailing: Switch(
                      activeColor: kMainColor,
                      value: bools['isManageDue']!,
                      onChanged: bools['isAdmin'] == true
                          ? null
                          : (status) {
                        setState(() {
                          bools['isManageDue'] = status;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    // print(isProduct);
                    Hive.box('newAdmin').putAll({
                      'isAdmin': bools['isAdmin'],
                      'isInventory': bools['isInventory'],
                      'isProducts': bools['isProduct'],
                      'isTransactions': bools['isTransaction'],
                      'isMakeCustomer': bools['isMakeCustomer'],
                      'isMakeAdmin': bools['isMakeAdmin'],
                      'isDeleteCustomer': bools['isDeleteCustomer'],
                      'isDeleteEmployee': bools['isDeleteEmployee'],
                      'isManageDue': bools['isManageDue'],
                      'isEditCustomer': bools['isEditCustomer'],
                    }).whenComplete(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordScreen(),
                        ),
                      );
                    });
                  },
                  child: Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: kMainColor),
                    ),
                    child: const Center(
                      child: Text(
                        'Next',
                        style: kButtonTextStyle,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
