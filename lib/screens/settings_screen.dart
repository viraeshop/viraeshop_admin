import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop/tokens/tokens_bloc.dart';
import 'package:viraeshop/tokens/tokens_event.dart';
import 'package:viraeshop/tokens/tokens_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_api/models/tokens/tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool switchValue = false, isLoading = true;
  String employeeId = Hive.box('adminInfo').get('adminId');
  String token = '';
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    try {
      _fcm
          .getToken(
        vapidKey: webPushKey,
      )
          .then((tokens) {
        debugPrint(tokens);
        token = tokens!;
        final tokenBloc = BlocProvider.of<TokensBloc>(context);
        tokenBloc.add(GetTokenEvent(tokenId: token, token: jWTToken));
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
      snackBar(
        text: '$e',
        context: context,
        color: kRedColor,
        duration: 500,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TokensBloc, TokenState>(
      listener: (context, state) {
        if (state is OnErrorTokenState) {
          setState(() {
            isLoading = false;
          });
          snackBar(
            text: state.message,
            context: context,
            color: kRedColor,
            duration: 500,
          );
        } else if (state is FetchedTokenState) {
          setState(() {
            isLoading = false;
            switchValue = state.token.notificationStatus;
          });
        } else if (state is RequestFinishedTokenState) {
          setState(() {
            isLoading = false;
            switchValue = state.response.result!['notificationStatus'] ?? false;
          });
          setState(() {});
          toast(
            context: context,
            title: state.response.result!['notificationStatus']
                ? 'Notification turned on'
                : 'Notification turned off',
          );
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: kMainColor,
        ),
        child: Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(FontAwesomeIcons.chevronLeft),
              iconSize: 20.0,
              color: kSubMainColor,
            ),
          ),
          body: ListView(
            children: [
              SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications,
                    color: kSubMainColor,
                    size: 20.0,
                  ),
                  title: const Text(
                    'Enable Notifications',
                    style: kProductNameStylePro,
                  ),
                  value: switchValue,
                  onChanged: (value) async {
                    snackBar(
                        text: 'Please wait, while enabling notifications',
                        context: context);
                    final tokenBloc = BlocProvider.of<TokensBloc>(context);
                    tokenBloc.add(UpdateTokenEvent(
                        token: jWTToken,
                        tokenId: token, tokenModel: {
                      'tokenId': token,
                      'notificationStatus': value,
                      'adminId': employeeId,
                    }));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
