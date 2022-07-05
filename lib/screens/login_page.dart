import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/decoration.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:viraeshop_admin/screens/verification_screen.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

class LoginPage extends StatefulWidget {
  static String path = '/login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  late UserCredential _userCredential;
  bool _isStart = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isStart,
      progressIndicator: CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        body: Center(
          child: LayoutBuilder(
            builder: (layoutContext, constraints) => Container(
              width: constraints.maxWidth > 600
                  ? MediaQuery.of(layoutContext).size.width * 0.40
                  : null,
              height: MediaQuery.of(layoutContext).size.height * 0.75,
              margin: EdgeInsets.all(16),
              decoration: kBoxDecoration,
              child: Column(
                // shrinkWrap: true,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: myField(
                        hint: 'Email',
                        input_type: 'email',
                        myController: _emailController),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: myField(
                      hint: 'Password',
                      input_type: 'password',
                      myController: _passwordController,
                      obscure: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: InkWell(
                      child: Container(
                        width: MediaQuery.of(layoutContext).size.width,
                        height: 58,
                        decoration: BoxDecoration(
                            color:
                                kSelectedTileColor, //Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Login",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      onTap: () async {
                        setState(() {
                          _isStart = true;
                        });
                        try {
                          _userCredential =
                              await _auth.signInWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (_userCredential != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .where('email',
                                    isEqualTo: _emailController.text)
                                .get()
                                .then(
                              (value) {
                                if (value.docs.isNotEmpty) {
                                  var adminInfo = value.docs.first;
                                  Hive.box('adminInfo').putAll({
                                    'email': adminInfo.get('email'),
                                    'name': adminInfo.get('name'),
                                    // 'password': adminInfo.get('password'),
                                    'adminId': adminInfo.get('adminId'),
                                    'isAdmin': adminInfo.get('isAdmin'),
                                    'isInventory': adminInfo.get('isInventory'),
                                    'isProducts': adminInfo.get('isProducts'),
                                    'isTransactions':
                                        adminInfo.get('isTransactions'),
                                    'isMakeCustomer':
                                        adminInfo.get('isMakeCustomer'),
                                    'isMakeAdmin': adminInfo.get('isMakeAdmin'),
                                  });
                                  setState(() {
                                    _isStart = false;
                                  });
                                  Navigator.popAndPushNamed(
                                      context, HomeScreen.path);
                                } else {
                                  setState(() {
                                    _isStart = false;
                                  });
                                  showMyDialog(
                                      'You are not authorized to use this App. Please contact Admin',
                                      context);
                                }
                              },
                            ).catchError(
                              (error) {
                                print(error);
                                setState(() {
                                  _isStart = false;
                                });
                                showMyDialog('Error occured', context);
                              },
                            );
                            // var loginDetails = jsonEncode({
                            //   'id': 'admin_testid',
                            // });

                            // addlogin(loginDetails).then((added) {
                            //   if (added) {
                            //    // progress.dismiss();
                            //     Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) => HomeScreen()));
                            //   } else {
                            //     //progress.dismiss();
                            //     showMyDialog(
                            //         'Could Not Save Login, try loggin in again',
                            //         context);
                            //   }
                            // });
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                            setState(() {
                              _isStart = false;
                            });
                            showMyDialog(
                                'No user found for that email', context);
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                            setState(() {
                              _isStart = false;
                            });
                            showMyDialog(
                                'You have entered a wrong password', context);
                          }
                        }
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => HomeScreen()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Dont have an account?'),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        VerificationScreen()));
                          },
                          child: Text(
                            'Sign-up',
                            style: TextStyle(color: kMainColor),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
