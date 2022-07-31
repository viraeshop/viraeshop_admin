import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../../components/styles/text_styles.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String number;
  final String? verificationId;
  final ConfirmationResult? confirmationResult;
  const PhoneVerificationScreen({
    required this.number,
    this.verificationId,
    this.confirmationResult,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
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
        body: Container(
          padding: const EdgeInsets.all(10.0),
          height: size.height,
          width: size.width,
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
                'Verify your Phone number',
                style: kSansTextStyle,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'We sent an sms with your confirmation code to this:',
                style: kProductNameStylePro,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                widget.number,
                textAlign: TextAlign.center,
                softWrap: true,
                style: kSansTextStyle1,
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                enabled: !isLoading,
                style: kProductNameStylePro,
                keyboardType: TextInputType.number,
                onChanged: (String value) async{
                  if(value.length == 6){
                    setState((){
                      isLoading = true;
                    });
                    if(!kIsWeb) {
                      final credentials = PhoneAuthProvider.credential(
                        smsCode: value,
                        verificationId: widget.verificationId!,
                      );
                      await _auth.signInWithCredential(credentials);
                    }else{
                      UserCredential userCredential = await widget.confirmationResult!.confirm(value);
                    }
                    setState((){
                      isLoading = false;
                    });
                    toast(context: context, title: 'Verified');
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter the code here...',
                  hintStyle: kTableCellStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: kSubMainColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: kNewMainColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
