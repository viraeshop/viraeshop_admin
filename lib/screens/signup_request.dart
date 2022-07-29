import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/product_info.dart';
import 'package:viraeshop_admin/screens/update_user.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

class SignupRequestsPage extends StatefulWidget {
  const SignupRequestsPage({Key? key}) : super(key: key);

  @override
  _SignupRequestsPageState createState() => _SignupRequestsPageState();
}

class _SignupRequestsPageState extends State<SignupRequestsPage> {
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
        iconTheme: IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(
          'General Customers',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: generalCrud.getSignups(),
          // future: FirebaseFirestore.instance
          //     .collection('order')
          //     .where('user_id', isEqualTo: user['id'])
          //     .where('order_by', isEqualTo: 'agent')
          //     .get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final myorders = snapshot.data!.docs;
              List<String> agentId = [];
              List<Map> customerList = [];
              myorders.forEach((element) {
                customerList.add({
                  'id': element.id,
                  'fullname': element.get('fullname'),
                  'email': element.get('email'),
                  'phone': element.get('phone'),
                  'password': element.get('password'),
                  'role': element.get('role'),
                  // 'image': element.get('image'),
                  'verification_status': element.get('verification_status'),
                  'activity_status': element.get('activity_status'),
                  'added_on': DateTime.fromMicrosecondsSinceEpoch(
                          element.get('added_on') * 1000)
                      .toString()
                      .split(" ")[0],
                });
                agentId.add(element.id);
              });
              return Container(
                child: customerList != null
                    ? ListView.builder(
                        itemCount: myorders.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListTile(
                                onTap: () {
                                  Map user_info = {
                                    'fullname': customerList[i]['fullname'],
                                    'email': customerList[i]['email'],
                                    'phone': customerList[i]['phone'],
                                    'password': customerList[i]['password'],
                                    'role': customerList[i]['role'],
                                    // 'image': element.get('image'),
                                    'verification_status': customerList[i]
                                        ['verification_status'],
                                    'activity_status': customerList[i]
                                        ['activity_status'],
                                  };

                                  // print(jsonEncode(user_info));
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UpdateUser(
                                                userInfo: user_info,
                                                userId: customerList[i]['id'],
                                              )));
                                },
                                leading: CircleAvatar(
                                  backgroundColor: kMainColor,
                                  child: Text('${i + 1}'), //Icon(Icons.person,
                                  // color: kBackgroundColor),
                                ),
                                trailing: Icon(Icons.arrow_right),
                                title: Text(
                                    '${customerList[i]['fullname']} (${customerList[i]['role']})',
                                    style: TextStyle(color: kMainColor)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${customerList[i]['email']}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text('${customerList[i]['phone']}'),
                                    Text(
                                        'STATUS: ${customerList[i]['verification_status']} | ${customerList[i]['activity_status']}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Text('Loading'),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
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

                SizedBox(height: 20),
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
                      children: [
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
              child: Text('Cancel'),
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
