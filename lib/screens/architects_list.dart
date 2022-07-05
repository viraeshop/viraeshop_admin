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

class ArchitectsPage extends StatefulWidget {
  const ArchitectsPage({Key? key}) : super(key: key);

  @override
  _ArchitectsPageState createState() => _ArchitectsPageState();
}

class _ArchitectsPageState extends State<ArchitectsPage> {
  GeneralCrud generalCrud = GeneralCrud();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(
          'Architects',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: generalCrud.getCustomers('architect'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final myorders = snapshot.data!.docs;
              List<String> docIds = [];
              List architectsList = [];
              myorders.forEach((element) {
                architectsList.add(element.data());
                docIds.add(element.id);
              });
              return Container(
                child: architectsList != null
                    ? ListView.builder(
                        itemCount: myorders.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ListTile(
                                onTap: () {
                                  Map<String, dynamic> userInfo = {
                                    'name': architectsList[i]['name'],
                                    'mobile': architectsList[i]['mobile'],
                                    'address': architectsList[i]['address'],
                                    'userId': architectsList[i]['userId'],
                                    'email': architectsList[i]['email'],
                                    'role': architectsList[i]['role'],
                                    'idType': architectsList[i]['idType'],
                                    'idImage': architectsList[i]['idImage'],
                                    'idNumber': architectsList[i]['idNumber'],
                                  };

                                  // print(jsonEncode(user_info));
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
                                  child: Text('${i + 1}'),
                                ),
                                trailing: Icon(Icons.arrow_right),
                                title: Text('${architectsList[i]['name']}',
                                    style: TextStyle(color: kMainColor)),
                                subtitle: Text(
                                  '${architectsList[i]['email']}',
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
