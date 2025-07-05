import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/customers/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/configs.dart';

import '../../components/styles/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String number;
  final String? verificationId;
  final ConfirmationResult? confirmationResult;
  const PhoneVerificationScreen({
    required this.number,
    this.verificationId,
    this.confirmationResult,
    Key? key,
  }) : super(key: key);

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
        body: BlocListener<CustomersBloc, CustomerState>(
          listener: (BuildContext context, state) {
            if (state is RequestFinishedCustomerState) {
              setState(() {
                isLoading = false;
              });
            }
          },
          child: Container(
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
                  onChanged: (String value) async {
                    final customerBloc =
                        BlocProvider.of<CustomersBloc>(context);
                    final customerId = Hive.box('customer').get('id');
                    UserCredential userCredential;
                    if (value.length == 6) {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        if (!kIsWeb) {
                          final credentials = PhoneAuthProvider.credential(
                            smsCode: value,
                            verificationId: widget.verificationId!,
                          );
                          userCredential =
                              await _auth.signInWithCredential(credentials);
                        } else {
                          userCredential =
                              await widget.confirmationResult!.confirm(value);
                        }
                        final jWTToken = Hive.box('adminInfo').get('token');
                        customerBloc.add(
                          UpdateCustomerEvent(
                            token: jWTToken,
                              customerId: customerId,
                              customerModel: {
                                'customerId': userCredential.user!.uid
                              }),
                        );
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        snackBar(
                          text: e.code,
                          context: context,
                          color: kRedColor,
                          duration: 30,
                        );
                      }
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
      ),
    );
  }
}
