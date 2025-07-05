
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/return/return_event.dart';
import 'package:viraeshop_bloc/return/return_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/return/return_bloc.dart';
import 'package:viraeshop_api/models/return/return.dart';
import 'package:viraeshop_api/utils/utils.dart';

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
    final returnBloc = BlocProvider.of<ReturnBloc>(context);
    final jWTToken = Hive.box('adminInfo').get('token');
    returnBloc.add(GetReturnsEvent(
      token: jWTToken,
    ));
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 3.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'Return History',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: false,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: BlocBuilder<ReturnBloc, ReturnState>(
          builder: (context, state) {
            if (state is OnErrorReturnState) {
              return Center(
                child: Text(
                  state.message,
                  style: kProductNameStylePro,
                ),
              );
            } else if (state is FetchedReturnsState) {
              int index = 0;
              List<ReturnModel> data = state.returns;
              List returns = [];
              for (var element in data) {
                returns.add(element.toJson());
                returns[index]['docId'] = element.id;
                index++;
              }
              return ListView.builder(
                      itemCount: returns.length,
                      itemBuilder: (context, i) {
                        Timestamp timestamp = dateFromJson(returns[i]['createdAt']);
                        DateTime dateTime = timestamp.toDate();
                        String date = dateTime.toString().split(' ')[0];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            side: const Border().bottom.copyWith(color: kStrokeColor,),
                          ),
                          contentPadding: const EdgeInsets.all(10.0),
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
                                date,
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
                    );
            }
            return const Center(
              heightFactor: 100.0,
              widthFactor: 100.0,
              child: CircularProgressIndicator(
                color: kMainColor,
              ),
            );
          }),
    );
  }
}
