import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/admin/admin_event.dart';
import 'package:viraeshop_bloc/admin/admin_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/admin/admins.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final labelStyle = const TextStyle(
    color: kSubMainColor,
    fontSize: 12.0,
    fontFamily: 'Montserrat',
    letterSpacing: 1.3,
  );
  @override
  Widget build(BuildContext context) {
    final adminBloc = BlocProvider.of<AdminBloc>(context);
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(color: kMainColor),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.close,
              color: kSubMainColor,
            ),
          ),
          title: const Text(
            'New User',
            style: kProductNameStylePro,
          ),
        ),
        body: BlocListener<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is RequestFinishedAdminState) {
              setState(() {
                isLoading = false;
              });
              toast(
                context: context,
                title: 'Successful',
              );
            } else if (state is OnErrorAdminState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: 'Try again ${state.message}',
                context: context,
              );
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(13.0),
              child: SizedBox(
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
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: kSubMainColor,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
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
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          final adminInfo = Hive.box('newAdmin').toMap();
                          Map<String, dynamic> adminMap = {
                            'email': adminInfo['email'],
                            'name': adminInfo['name'],
                            'isAdmin': adminInfo['isAdmin'],
                            'isInventory': adminInfo['isInventory'],
                            'isProducts': adminInfo['isProducts'],
                            'isTransactions': adminInfo['isTransactions'],
                            'isMakeCustomer': adminInfo['isMakeCustomer'],
                            'isMakeAdmin': adminInfo['isMakeAdmin'],
                            'isDeleteCustomer': adminInfo['isDeleteCustomer'],
                            'isDeleteEmployee': adminInfo['isDeleteEmployee'],
                            'isManageDue': adminInfo['isManageDue'],
                            'isEditCustomer': adminInfo['isEditCustomer'],
                          };
                          try {
                            final user = await NetworkUtility.registerUserEmail(
                                adminInfo['email'], _passwordController.text);
                            adminMap['adminId'] = user.user!.uid;
                            final jWTToken = Hive.box('adminInfo').get('token');
                            adminBloc.add(
                              AddAdminEvent(
                                token: jWTToken,
                                adminModel: AdminModel.fromJson(adminMap),
                              ),
                            );
                            Hive.box('newAdmin').clear();
                          } on FirebaseAuthException catch (e) {
                            if (kDebugMode) {
                              print(e.message);
                            }
                            setState(() {
                              isLoading = false;
                            });
                            snackBar(
                              text: e.message!,
                              context: context,
                              color: kRedColor,
                              duration: 30,
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
                        child: const Center(
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
      ),
    );
  }
}
