import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

class ReturnHistory extends StatefulWidget {
  const ReturnHistory({Key? key}) : super(key: key);

  @override
  _ReturnHistoryState createState() => _ReturnHistoryState();
}

class _ReturnHistoryState extends State<ReturnHistory> {
  GeneralCrud generalCrud = GeneralCrud();
  var user = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getlogin().then((curruser) {
    //   setState(() {
    //     user = jsonDecode(curruser);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kSelectedTileColor),
        elevation: 3.0,
        backgroundColor: kBackgroundColor,
        title: Text(
          'Return History',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: false,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: generalCrud.getReturn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                heightFactor: 100.0,
                widthFactor: 100.0,
                child: CircularProgressIndicator(
                  color: kMainColor,
                ),
              );
            } else if (snapshot.hasData) {
              int index = 0;
              final data = snapshot.data!.docs;
              print(data);
              List returns = [];
              data.forEach((element) {
                returns.add(element.data());
                returns[index]['docId'] = element.id;
                index++;
              });
              return returns.isNotEmpty
                  ? ListView.builder(
                      itemCount: returns.length,
                      itemBuilder: (context, i) {
                        Timestamp timestamp = returns[i]['date'];
                        DateTime dateTime = timestamp.toDate();
                        String date = dateTime.toString().split(' ')[0];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            side: Border().bottom.copyWith(color: kStrokeColor,),
                          ),
                          contentPadding: EdgeInsets.all(10.0),
                          tileColor: kBackgroundColor,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: '${returns[i]['image']}',
                              height: 150.0,
                              width: 100.0,
                              errorWidget: (context, url, childs) {
                                return Image.asset(
                                  'assets/default.jpg',
                                  height: 150.0,
                                  width: 100.0,
                                );
                              },
                            ),
                          ),
                          title: Text(
                            returns[i]['productName'],
                            style: kTableCellStyle,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${returns[i]['productPrice']} BDT',
                                style: kTotalTextStyle,
                              ),
                              Text(
                                '${returns[i]['reason']}',
                                style: kProductNameStylePro,
                              ),
                              Text(
                                '$date',
                                style: kProductNameStylePro,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${returns[i]['customerId']}',
                                    style: kProductNameStylePro,
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      child: Center(
                        child: Text(
                          'Oop\'s an error occured',
                          style: kProductNameStylePro,
                        ),
                      ),
                    );
            } else {
              return Center(
                child: Text(
                  'Oop\'s an error occured',
                  style: kProductNameStylePro,
                ),
              );
            }
          }),
    );
  }
}
