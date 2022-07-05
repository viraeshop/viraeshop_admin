import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/password_screen.dart';

class PermissionPage extends StatefulWidget {
  final bool isEdit;
  var adminInfo;
  PermissionPage({this.isEdit = false, adminInfo = ''});
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
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: kSubMainColor,
          ),
        ),
        title: Text(
          'New User',
          style: kProductNameStylePro,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(13.0),
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              children: [
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
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
                      });
                    },
                  ),
                ),
                ListTile(
                  // leading: Icon(Icons.dark_mode),
                  title: Text(
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
                  title: Text(
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
                  title: Text(
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
                  title: Text(
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
                  title: Text(
                    'Create user',
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
                  }).whenComplete(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordScreen(),
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
                  child: Center(
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
    );
  }
}
