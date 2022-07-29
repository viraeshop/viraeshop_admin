import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../../components/styles/text_styles.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;
  const EmailConfirmationScreen({
    required this.email,
  });

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0.0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: kAppBarTitleTextStyle,
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const SizedBox(
                    height: 30.0,
                  ),
                  Image.asset(
                    'assets/images/email.gif',
                    height: size.height * .3,
                    width: double.infinity,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    'Confirm your email address',
                    style: kSansTextStyle,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    'We sent a confirmation email to:',
                    style: kProductNameStylePro,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: kSansTextStyle1,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    'Check your email and click on the confirmation link to continue',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: kProductNameStylePro,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    NetworkUtility.verifyEmail().then((value) {
                      toast(context: context, title: 'Sent');
                    }).catchError((error) {
                      toast(context: context, title: 'Failed try again');
                    });
                  },
                  child: const Text(
                    'Resend email',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20.0,
                      color: kNewTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
