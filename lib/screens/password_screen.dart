import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordController = TextEditingController();
  final labelStyle = TextStyle(
    color: kSubMainColor,
    fontSize: 12.0,
    fontFamily: 'Montserrat',
    letterSpacing: 1.3,
  );
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(color: kMainColor),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
              color: kSubMainColor,
            ),
          ),
          title: Text(
            'New User',
            style: kProductNameStylePro,
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(13.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.92,
              width: MediaQuery.of(context).size.width,
              child: Stack(fit: StackFit.expand, children: [
                FractionallySizedBox(
                  heightFactor: 0.9,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kSubMainColor,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: kMainColor,
                            ),
                          ),
                          labelText: "Password*",
                          labelStyle: labelStyle,
                        ),
                      ),
                      // SizedBox(
                      //   height: 5.0,
                      // ),
                      // Text(
                      //   '*At least 6 characters',
                      //   style: kProductNameStyle,
                      // ),
                    ],
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: 0.1,
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });
                        final adminInfo = Hive.box('newAdmin').toMap();
                        Map<String, dynamic> adminMap = {
                          'email': adminInfo['email'],
                          'name': adminInfo['name'],
                          'adminId': adminInfo['adminId'],
                          'isAdmin': adminInfo['isAdmin'],
                          'isInventory': adminInfo['isInventory'],
                          'isProducts': adminInfo['isProducts'],
                          'isTransactions': adminInfo['isTransactions'],
                          'isMakeCustomer': adminInfo['isMakeCustomer'],
                          'isMakeAdmin': adminInfo['isMakeAdmin'],
                        };
                        try {
                          AdminCrud()
                              .addAdmin(adminInfo['adminId'], adminMap)
                              .then((value) {
                            try {
                              _auth
                                  .createUserWithEmailAndPassword(
                                      email: adminInfo['email'],
                                      password: _passwordController.text)
                                  .then((value) {
                                setState(() {
                                  isLoading = false;
                                });
                                print('done creating admin');
                                Hive.box('newAdmin').clear();
                                Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(builder: (context) {
                                  return HomeScreen();
                                }), (route) => false);
                              }).catchError((error) {
                                print(error);
                                setState(() {
                                  isLoading = false;
                                });
                                snackBar(
                                    text: '${error.toString()}',
                                    context: context);
                              });
                            } on FirebaseAuthException catch (e) {
                              print(e);
                              setState(() {
                                isLoading = false;
                              });
                              showDialogBox(
                                buildContext: context,
                                msg: '${e.message}',
                              );
                            }
                          });
                        } catch (e) {
                          print(e);
                          setState(() {
                            isLoading = false;
                          });
                          showDialogBox(
                            buildContext: context,
                            msg: 'Fialed to create new User. Try again',
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: kSubMainColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: kBackgroundColor,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
