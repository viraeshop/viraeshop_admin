import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/product_info.dart';
import 'package:viraeshop_admin/screens/update_user.dart';
import 'package:viraeshop_admin/screens/user_profile.dart';
import 'package:viraeshop_admin/screens/user_profile_info.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

import 'customers/customer_list.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({Key? key}) : super(key: key);

  @override
  _AgentsPageState createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  GeneralCrud generalCrud = GeneralCrud();
  var user = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlogin().then((curruser) {
      setState(() {
        user = jsonDecode(curruser);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'Agents',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: const Customers(
        role: 'agents',
      ),
    );
  }

  // Dialog
  Future<void> _showMyDialog({var title = "Error", var msg}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('This is a demo alert dialog.'),
                // Text('$msg'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: myField(hint: 'Reason'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: myField(hint: 'Quantity'),
                ),

                const SizedBox(height: 20),
                InkWell(
                  child: Container(
                    width: double.infinity, //MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                        color:
                            kSelectedTileColor, //Theme.of(context).accentColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Return",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    // addProduct();
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
