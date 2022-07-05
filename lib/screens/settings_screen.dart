import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool switchValue = false, isLoading = true;
  String employeeId = Hive.box('adminInfo').get('adminId');
  String token = '';
  @override
  void initState() {
    // TODO: implement initState
    try {
      _fcm
          .getToken(
        vapidKey: webPushKey,
      )
          .then((tokens) {
        print(tokens);
        token = tokens!;
        FirebaseFirestore.instance
            .collection('notifications')
            .doc('token')
            .collection('tokens')
            .doc(tokens)
            .get()
            .then((snapshot) {
          setState(() {
            switchValue = snapshot.get('notificationStatus');
            isLoading = false;
          });
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
        });
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      snackBar(text: 'Error occured!', context: context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(FontAwesomeIcons.chevronLeft),
            iconSize: 20.0,
            color: kSubMainColor,
          ),
        ),
        body: Container(
          child: ListView(
            children: [
              SwitchListTile(
                  secondary: Icon(
                    Icons.notifications,
                    color: kSubMainColor,
                    size: 20.0,
                  ),
                  title: Text(
                    'Enable Notifications',
                    style: kProductNameStylePro,
                  ),
                  value: switchValue,
                  onChanged: (value) async {
                    snackBar(
                        text: 'Please wait, while enabling notifications',
                        context: context);
                    try {
                      FirebaseFirestore.instance
                          .collection('notifications')
                          .doc('token')
                          .collection('tokens')
                          .doc(token)
                          .set({
                        'token': token,
                        'notificationStatus': value,
                        'employeeId': employeeId,
                      }).then((snapshot) {
                        setState(() {
                          switchValue = value;
                        });
                        snackBar(
                          text: value
                              ? 'Notification turned on'
                              : 'Notification turned off',
                          context: context,
                          duration: 10,
                        );
                      });
                    } catch (e) {
                      print(e);
                      snackBar(
                          text: 'Failed please try again',
                          context: context,
                          duration: 10,
                        );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
