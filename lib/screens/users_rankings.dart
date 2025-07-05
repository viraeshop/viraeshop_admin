import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/user_profile.dart';

class UserRanking extends StatefulWidget {
  const UserRanking({Key? key}) : super(key: key);

  @override
  _UserRankingState createState() => _UserRankingState();
}

class _UserRankingState extends State<UserRanking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: kSelectedTileColor),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: const Text(
            'User Rankings',
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
            itemCount: 3,
            itemBuilder: (BuildContext context, int i) {
              var rank = '';
              if (i == 0) {
                rank = '#1 Diamond';
              }
              if (i == 1) {
                rank = '#2 Gold';
              }
              if (i == 2) {
                rank = '#3 Silver';
              }
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
                    'Name ${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'user@mail.com',
                  ),
                  trailing: Text(
                    '($rank)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
