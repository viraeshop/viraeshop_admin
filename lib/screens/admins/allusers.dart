import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/admin/admin_event.dart';
import 'package:viraeshop_bloc/admin/admin_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/admins/edit_employee.dart';
import 'package:viraeshop_api/models/admin/admins.dart';

import 'new_admin_user.dart';

class AllUserScreen extends StatefulWidget {
  static const String path = '/employees';
  const AllUserScreen({Key? key}) : super(key: key);

  @override
  _AllUserScreenState createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  @override
  void initState() {
    // TODO: implement initState
    final adminBloc = BlocProvider.of<AdminBloc>(context);
    final jWTToken = Hive.box('adminInfo').get('token');
    adminBloc.add(GetAdminsEvent(
      token: jWTToken
    ));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            FontAwesomeIcons.chevronLeft,
            color: kSubMainColor,
          ),
          iconSize: 15.0,
        ),
        title: const Text(
          'Users',
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
            icon: const Icon(FontAwesomeIcons.userPlus),
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
  return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is FetchedAdminsState) {
          List<AdminModel> users = state.adminList ?? [];
          if (kDebugMode) {
            print(users.length);
          }
          return SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  users.length,
                      (int i) {
                    String user = users[i].name;
                    return InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return EditUserScreen(adminInfo: users[i].toJson());
                            }));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: const BoxDecoration(
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
                            user.split(' ')[0],
                            style: kProductNameStylePro,
                          ),
                          subtitle: Text(
                            users[i].email,
                            style: kProductNameStylePro,
                          ),
                          trailing: const Column(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Admin',
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
              ),
            ),
          );
        } else if (state is OnErrorAdminState) {
          String error = state.message;
          return Center(
            child: Text(
              error,
              style: kProductNameStylePro,
            ),
          );
        } else {
          return const Center(
            child: Text(
              'Loading please wait.....',
              style: kProductNameStylePro,
            ),
          );
        }
      });
}
