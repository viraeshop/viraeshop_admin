import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/decoration.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';

import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
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
            builder: (context, constraints) => Container(
              width: constraints.maxWidth > 600
                  ? MediaQuery.of(context).size.width * 0.40
                  : null,
              height: MediaQuery.of(context).size.height * 0.8,
              margin: EdgeInsets.all(16),
              decoration: kBoxDecoration,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: myField(
                        hint: 'Name',
                        input_type: 'text',
                        myController: _nameController),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: myField(
                        hint: 'username/ID',
                        input_type: 'text',
                        myController: _usernameController),
                  ),
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
                        width: MediaQuery.of(context).size.width,
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
                              "Sign Up",
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
                              await _auth.createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          // _emailController.clear();
                          // _passwordController.clear();
                          if (_userCredential != null) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(_usernameController.text)
                                .set({
                              'email': _emailController.text,
                              'name': _nameController.text,
                              'password': _passwordController.text,
                              'adminId': _usernameController.text,
                              'isAdmin': true,
                              'isInventory': true,
                              'isProducts': true,
                              'isTransactions': true,
                              'isMakeCustomer': true,
                              'isMakeAdmin': true,
                            }).then((value) {
                              Hive.box('adminInfo').putAll({
                                'email': _emailController.text,
                                'name': _nameController.text,
                                'password': _passwordController.text,
                                'adminId': _usernameController.text,
                                'isAdmin': true,
                                'isInventory': true,
                                'isProducts': true,
                                'isTransactions': true,
                                'isMakeCustomer': true,
                                'isMakeAdmin': true,
                              });
                              setState(() {
                                _isStart = true;
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                              setState(() {
                                _isStart = false;
                              });
                            }).catchError((error) {
                              print(error);
                              setState(() {
                                _isStart = false;
                              });
                              showDialogBox(
                                  buildContext: context, msg: 'failed');
                            });
                          }
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            print('The password provided is too weak.');
                            setState(() {
                              _isStart = false;
                            });
                            showMyDialog(
                                'The password provided is too weak.', context);
                          } else if (e.code == 'email-already-in-use') {
                            print('The account already exists for that email.');
                            setState(() {
                              _isStart = false;
                            });
                            showMyDialog(
                                'The account already exists for that email.',
                                context);
                          }
                        } catch (e) {
                          print(e.toString());
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Have an account? '),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return LoginPage();
                                },
                              ),
                            );
                          },
                          child: Text(
                            'Login',
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
