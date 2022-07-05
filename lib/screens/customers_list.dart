import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/product_info.dart';
import 'package:viraeshop_admin/screens/update_user.dart';
import 'package:viraeshop_admin/screens/user_profile_info.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  GeneralCrud generalCrud = GeneralCrud();

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
      body: StreamBuilder<QuerySnapshot>(
          stream: generalCrud.getCustomers('general'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final myorders = snapshot.data!.docs;
              List<String> docIds = [];
              List customerList = [];
              myorders.forEach((element) {
                customerList.add(element.data());
                docIds.add(element.id);
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
                                  Map<String, dynamic> userInfo = {
                                    'name': customerList[i]['name'],
                                    'mobile': customerList[i]['mobile'],
                                    'address': customerList[i]['address'],
                                    'userId': customerList[i]['userId'],
                                    'email': customerList[i]['email'],
                                    'role': customerList[i]['role'],
                                  };
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserProfileInfo(
                                                userInfo: userInfo,
                                                docId: docIds[i],
                                              )));
                                },
                                leading: CircleAvatar(
                                  radius: 60.0,
                                  backgroundColor: kNewTextColor,
                                  child: Text('${i + 1}'), //Icon(Icons.person,
                                  // color: kBackgroundColor),
                                ),
                                trailing: Icon(Icons.arrow_right),
                                title: Text('${customerList[i]['name']} ',
                                    style: kCategoryNameStylePro),
                                subtitle: Text(
                                  '${customerList[i]['email']}',
                                  style: kProductNameStylePro,
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
}
