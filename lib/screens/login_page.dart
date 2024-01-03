import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/admin/admin_event.dart';
import 'package:viraeshop_bloc/admin/admin_state.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/admins/forgot_password.dart';
import 'package:viraeshop_admin/screens/verification_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  static String path = '/login';
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserCredential _userCredential;
  bool _isStart = false;
  bool obscure = true;
  late String token;
  @override
  void initState() {
    // TODO: implement initState
    final adminInfo = Hive.box('adminInfo');
    if (adminInfo.isNotEmpty) {
      _emailController.text = adminInfo.get('email', defaultValue: '');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: _isStart,
        progressIndicator: const CircularProgressIndicator(
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
                margin: const EdgeInsets.all(16),
                decoration: kBoxDecoration,
                child: BlocListener<AdminBloc, AdminState>(
                  listener: (BuildContext context, state) {
                    if (state is FetchedAdminState) {
                      final adminInfo = state.adminModel;
                      Hive.box('adminInfo').putAll({
                        'email': adminInfo.email,
                        'name': adminInfo.name,
                        'adminId': adminInfo.adminId,
                        'isAdmin': adminInfo.isAdmin,
                        'isInventory': adminInfo.isInventory,
                        'isProducts': adminInfo.isProducts,
                        'isTransactions': adminInfo.isTransactions,
                        'isMakeCustomer': adminInfo.isMakeCustomer,
                        'isMakeAdmin': adminInfo.isMakeAdmin,
                        'isManageDue': adminInfo.isManageDue,
                        'isDeleteCustomer': adminInfo.isDeleteCustomer,
                        'isDeleteEmployee': adminInfo.isDeleteEmployee,
                        'isEditCustomer': adminInfo.isEditCustomer,
                        'active': adminInfo.active,
                        'token': token ?? '',
                      });
                      setState(() {
                        _isStart = false;
                      });
                      Navigator.popAndPushNamed(context, HomeScreen.path);
                    } else if (state is OnErrorAdminState) {
                      setState(() {
                        _isStart = false;
                      });
                      showMyDialog(
                        state.message,
                        context,
                      );
                    }
                  },
                  child: Column(
                    // shrinkWrap: true,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Login', style: kProductNameStyle,),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: NewTextField(
                          labelText: 'Email',
                          hintText: 'Enter your email address',
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: NewTextField(
                          hintText: 'Enter your password',
                          labelText: 'Password',
                          keyboardType: TextInputType.number,
                          secure: obscure,
                          controller: _passwordController,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                            icon: const Icon(Icons.remove_red_eye),
                            color: !obscure ? kSubMainColor : kNewMainColor,
                          ),
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
                              children: const [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          onTap: () async {
                            final adminBloc =
                                BlocProvider.of<AdminBloc>(context);
                            setState(() {
                              _isStart = true;
                            });
                            try {
                              _userCredential =
                                  await _auth.signInWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );
                              token = (await _userCredential.user!.getIdToken())!;
                              adminBloc.add(GetAdminEvent(
                                  adminId: _userCredential.user!.uid,
                                  token: token));
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                                debugPrint('No user found for that email.');
                                setState(() {
                                  _isStart = false;
                                });
                                showMyDialog(
                                  'No user found for that email',
                                  context,
                                );
                              } else if (e.code == 'wrong-password') {
                                debugPrint(
                                    'Wrong password provided for that user.');
                                setState(() {
                                  _isStart = false;
                                });
                                showMyDialog(
                                    'You have entered a wrong password',
                                    context);
                              }else {
                                setState(() {
                                  _isStart = false;
                                });
                                showMyDialog(
                                    e.message!,
                                    context);
                              }
                            }
                          },
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot password?',
                                    style: kCategoryNameStylePro,
                                  )),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
