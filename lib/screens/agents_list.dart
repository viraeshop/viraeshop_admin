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
        iconTheme: IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(
          'Agents',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: generalCrud.getCustomers('agents'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final myorders = snapshot.data!.docs;
              List<String> docIds = [];
              List agentList = [];
              num storeCredit = 0.0;
              myorders.forEach((element) {
                agentList.add(element.data());
                docIds.add(element.id);
                storeCredit += element.get('wallet');
              });
              return Container(
                child: agentList.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          FractionallySizedBox(
                            alignment: Alignment.topCenter,
                            heightFactor: 0.88,
                            child: ListView.builder(
                              itemCount: myorders.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: ListTile(
                                      onTap: () {
                                        Map<String, dynamic> userInfo = {
                                          'name': agentList[i]['name'],
                                          'mobile': agentList[i]['mobile'],
                                          'address': agentList[i]['address'],                                          
                                          'userId': agentList[i]['userId'],                                        
                                          'email': agentList[i]['email'],                                          
                                          'binImage': agentList[i]['binImage'],
                                          'tinImage': agentList[i]['tinImage'],
                                          'binNumber': agentList[i]['binNumber'],
                                          'role': agentList[i]['role'],
                                          'wallet': agentList[i]['wallet'],
                                        };
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserProfileInfo(
                                                      userInfo: userInfo,
                                                      docId: docIds[i],
                                                    )));
                                      },
                                      leading: CircleAvatar(
                                        radius: 60.0,                                        
                                        backgroundColor: kNewTextColor,
                                        child: Text(
                                            '${i + 1}'), //Icon(Icons.person,
                                        // color: kBackgroundColor),
                                      ),
                                      trailing: Icon(Icons.arrow_right),
                                      title: Text('${agentList[i]['name']} ',
                                          style: TextStyle(color: kMainColor)),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${agentList[i]['email']}',
                                            style: kProductNameStylePro,
                                          ),                                        
                                          Text(
                                            'Wallet: ${agentList[i]['wallet'].toString()}৳',
                                            style: kProductPriceStylePro,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.bottomCenter,
                            heightFactor: 0.12,
                            child: Container(
                              width: double.infinity,
                              color: kSubMainColor,
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Receivables',
                                        style: TextStyle(
                                          color: kBackgroundColor,
                                          fontSize: 15.0,
                                          letterSpacing: 1.3,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      Text(
                                        'BDT 0.0',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 15.0,
                                          letterSpacing: 1.3,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Store Credits',
                                        style: TextStyle(
                                          color: kBackgroundColor,
                                          fontSize: 15.0,
                                          letterSpacing: 1.3,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      Text(
                                        'BDT ${storeCredit.toString()}',
                                        style: TextStyle(
                                          color: kMainColor,
                                          fontSize: 15.0,
                                          letterSpacing: 1.3,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
