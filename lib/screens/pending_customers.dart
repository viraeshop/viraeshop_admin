import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/add_user.dart';
import 'package:viraeshop_admin/screens/edit_employee.dart';

import 'new_admin_user.dart';

class PendingCustomers extends StatefulWidget {
  const PendingCustomers({Key? key}) : super(key: key);

  @override
  _PendingCustomersState createState() => _PendingCustomersState();
}

class _PendingCustomersState extends State<PendingCustomers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            FontAwesomeIcons.chevronLeft,
            color: kSubMainColor,
          ),
          iconSize: 15.0,
        ),
        title: Text(
          'Pending customer\'s',
          style: kProductNameStylePro,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return NewAdmin();
                },
              ),
            ),
            icon: Icon(FontAwesomeIcons.userPlus),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
        ],
      ),
      body: architect(),
    );
  }
}

Widget architect() {
  return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pending_cutomers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(
              'Loading Plaese wait.....',
              style: kProductNameStylePro,
            ),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!.docs;
          List users = [];
          data.forEach((element) {
            users.add(element.data());
          });
          print(data.length);
          return Container(
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: data.isNotEmpty
                  ? Column(
                      children: List.generate(
                        users.length,
                        (int i) {
                          String user = users[i]['name'];
                          return InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return EditUserScreen(adminInfo: users[i]);
                              },),);
                            },
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: BoxDecoration(
                                color: kBackgroundColor,
                                border: Border(
                                  bottom: BorderSide(color: Colors.black26),
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: kSubMainColor,
                                  radius: 40.0,
                                  child: Text(
                                    user.substring(0, 2),
                                    style: kDrawerTextStyle2,
                                  ),
                                ),
                                title: Text(
                                  '${user.split(' ')[0]}',
                                  style: kProductNameStylePro,
                                ),
                                subtitle: Text(
                                  '${users[i]['email']}',
                                  style: kProductNameStylePro,
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'New',
                                      style: kProductNameStylePro,
                                    ),
                                    Icon(
                                      FontAwesomeIcons.chevronRight,
                                      color: kSubMainColor,
                                      size: 10.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Text(
                        'Failed to fetch customers',
                        style: kProductNameStylePro,
                      ),
                    ),
            ),
          );
        } else {
          return Center(
            child: Text(
              'Failed to fetch customers',
              style: kProductNameStylePro,
            ),
          );
        }
      });
}
