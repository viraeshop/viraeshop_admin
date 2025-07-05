import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/user_profile.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: kSelectedTileColor),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: const Text(
            'User List',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
          // bottom: TabBar(
          //   tabs: tabs,
          // ),
        ),
        body: Container(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (BuildContext context, int i) {
              return Container(
                child: ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const UserProfile()));
                  },
                  leading: const CircleAvatar(
                    backgroundColor: kMainColor,
                    child: Icon(Icons.person, color: kBackgroundColor),
                  ),
                  title: Text(
                    'Name $i - (${(i % 2) == 0 ? ('Admin') : ('Staff')})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'user@mail.com',
                  ),
                  trailing: const Icon(Icons.arrow_right_sharp),
                ),
              );
            },
          ),
        ));
  }
}
