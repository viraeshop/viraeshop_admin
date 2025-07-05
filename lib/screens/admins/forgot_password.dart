import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/reusable_widgets/send_button.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';


import '../../components/styles/colors.dart';
import '../../components/styles/text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  Future<void> _passwordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            iconSize: 20.0,
            color: kSubMainColor,
          ),
          title: const Text(
            'Reset Password',
            style: kAppBarTitleTextStyle,
          ),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock,
                      color: kMainColor,
                      size: 50.0,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  'Forgot Password',
                  style: kSansTextStyle,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text(
                  'Please provide your email and we will send you a link to reset your password',
                  softWrap: true,
                  style: kProductNameStylePro,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                NewTextField(
                  controller: controller,
                  hintText: 'Enter your email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20.0,
                ),
                SendButton(
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });
                    _passwordReset(controller.text).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                      showMyDialog(
                          'Password reset email was sent, check your inbox',
                          context);
                    }).catchError((error) {
                      setState(() {
                        isLoading = false;
                      });
                      showMyDialog(
                          'Failed to send password reset email', context);
                    });
                  },
                  title: 'Reset Password',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
