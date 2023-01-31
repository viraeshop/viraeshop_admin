import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:random_string/random_string.dart';
import 'package:viraeshop/customers/barrel.dart';
import 'package:viraeshop/customers/customers_bloc.dart';
import 'package:viraeshop/customers/customers_event.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/dialog_button.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/customers/phone_verification_screen.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/customers/customers.dart';

class RegisterCustomer extends StatefulWidget {
  const RegisterCustomer({Key? key}) : super(key: key);

  @override
  State<RegisterCustomer> createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final CustomerPreferences _preferences = CustomerPreferences();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> userInfo = {};
  String dropdownValue = 'general';
  late String verificationId;
  bool onError = false;
  bool isLoading = false;
  static const String countryCode = '+234';
  @override
  void initState() {
    // TODO: implement initState
    _preferences.addControllers = TextEditingController();
    _preferences.addHint = 'Password';
    _preferences.addIconData = Icons.password;
    // final customerBloc = BlocProvider.of<CustomersBloc>(context);
    // customerBloc.add(GetCustomersEvent(query: 'all'));
    super.initState();
  }
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          title: const Text(
            'Register new Customer',
            style: kAppBarTitleTextStyle,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
        ),
        body: BlocListener<CustomersBloc, CustomerState>(
          listener: (context, state) async {
            final customerBloc = BlocProvider.of<CustomersBloc>(context);
            if (state is CheckedCustomerState) {
              bool exist = state.exists.exists;
              userInfo = {
                'name': _preferences.getControllers[0].text.toUpperCase(),
                'mobile': countryCode + _preferences.getControllers[1].text,
                'email': _preferences.getControllers[2].text,
                'address': _preferences.getControllers[3].text,
                'role': dropdownValue,
              };
              if (dropdownValue == 'architect' || dropdownValue == 'agents') {
                userInfo['businessName'] = _preferences.getControllers[5].text;
              }
              if (dropdownValue == 'agents') {
                userInfo['wallet'] = 0.0;
              }
              String uid = '';
              if (exist) {
                setState(() {
                  isLoading = false;
                });
                snackBar(
                  text: 'Account already existed',
                  context: context,
                  color: kRedColor,
                  duration: 10,
                );
              } else {
                try {
                  if (_preferences.getControllers[2].text.isNotEmpty) {
                    final UserCredential user =
                        await NetworkUtility.registerUserEmail(
                      _preferences.getControllers[2].text,
                      _preferences.getControllers[4].text,
                    );
                    uid = user.user!.uid;
                  } else {
                    uid = randomAlphaNumeric(15);
                  }
                  userInfo['customerId'] = uid;
                  customerBloc.add(AddCustomerEvent(
                    token: jWTToken,
                      customerModel: CustomerModel.fromJson(userInfo)));
                } on FirebaseAuthException catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                  if (kDebugMode) {
                    print(e.message);
                  }
                  snackBar(
                      text: e.message!,
                      context: context,
                      color: kRedColor,
                      duration: 400);
                }
              }
            } else if (state is RequestFinishedCustomerState) {
              if (kDebugMode) {
                print('Done adding customer');
              }
              final String number =
                  countryCode + _preferences.getControllers[1].text;
              userInfo['id'] = userInfo['customerId'];
              userInfo.remove('customerId');
              Hive.box('customer').putAll(userInfo);
              toast(
                  context: context,
                  title: 'Sending verification code please wait....');
              try {
                if (!kIsWeb) {
                  await _auth.verifyPhoneNumber(
                      phoneNumber: number,
                      verificationCompleted:
                          (PhoneAuthCredential credentials) {},
                      verificationFailed: (FirebaseAuthException e) {
                        if (kDebugMode) {
                          print(e.code);
                        }
                        if (e.code == 'invalid-phone-number') {
                          if (kDebugMode) {
                            print('The provided phone number is not valid.');
                          }
                          snackBar(
                              duration: 25,
                              text: 'The provided phone number is not valid.',
                              context: context,
                              color: kRedColor);
                        }
                        snackBar(
                          duration: 25,
                          text: e.code,
                          context: context,
                          color: kRedColor,
                        );
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return PhoneVerificationScreen(
                                number: _preferences.getControllers[1].text,
                                verificationId: verificationId,
                              );
                            },
                          ),
                        );
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {});
                } else {
                  ConfirmationResult confirmationResult =
                      await _auth.signInWithPhoneNumber(number);
                  Future.delayed(const Duration(milliseconds: 0), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PhoneVerificationScreen(
                            number: _preferences.getControllers[1].text,
                            confirmationResult: confirmationResult,
                          );
                        },
                      ),
                    );
                  });
                }
              } on FirebaseAuthException catch (e) {
                if (kDebugMode) {
                  print(e);
                }
                snackBar(
                  text: e.message!,
                  context: context,
                  color: kRedColor,
                  duration: 10,
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            } else if (state is OnErrorCustomerState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
                duration: 30,
              );
            }
          },
          child: Form(
            key: _formKey,
            child: Container(
              height: screenSize.height,
              width: screenSize.width,
              color: kBackgroundColor,
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: List.generate(
                        _preferences.getControllers.length,
                        (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NewTextField(
                            secure: index == 4,
                            controller: _preferences.getControllers[index],
                            maxLength: index == 1
                                ? 11
                                : index == 4
                                    ? 15
                                    : 1000,
                            prefixIcon: SizedBox(
                              width: index == 1 ? 100 : 30,
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 7.0,
                                  ),
                                  Icon(
                                    _preferences.getIconData[index],
                                    color: kSubMainColor,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  if (index == 1)
                                    const Text(
                                      countryCode,
                                      style: kTableCellStyle,
                                    ),
                                ],
                              ),
                            ),
                            labelText: _preferences.getHint[index],
                            validator: index == 1 ? (value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter phone number';
                              }
                              return null;
                            } : null,
                          ),
                        ),
                      ),
                    ),
                    DropdownButtonFormField(
                      value: dropdownValue,
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text(
                            'General',
                            style: kTableCellStyle,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'agents',
                          child: Text(
                            'Agent',
                            style: kTableCellStyle,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'architect',
                          child: Text(
                            'Architect',
                            style: kTableCellStyle,
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          dropdownValue = value!;
                          if (value != 'general' &&
                              _preferences.getHint.length == 5) {
                            _preferences.addControllers = TextEditingController();
                            _preferences.addHint = 'Business name';
                            _preferences.addIconData = Icons.business;
                          } else if (value == 'general' &&
                              _preferences.getHint.length > 5) {
                            _preferences.getControllers.removeLast();
                            _preferences.getHint.removeLast();
                            _preferences.getIconData.removeLast();
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: kSubMainColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kNewMainColor),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    DialogButton(
                        radius: 10.0,
                        height: 50.0,
                        width: double.infinity,
                        onTap: () async {
                          if (_formKey.currentState!.validate()){
                            setState(() {
                              isLoading = true;
                            });
                            final String number =
                                countryCode + _preferences.getControllers[1].text;
                            print(number);
                            final customerBloc =
                            BlocProvider.of<CustomersBloc>(context);

                            customerBloc.add(
                              CheckCustomerEvent(
                                  token: jWTToken,
                                  mobile: number),
                            );
                          }
                          // List searchKeywords = _preferences.getControllers[0].text
                          //     .toUpperCase()
                          //     .characters
                          //     .toList();
                          // if (dropdownValue == 'architect' ||
                          //     dropdownValue == 'agents') {
                          //   userInfo['business_name'] =
                          //       _preferences.getControllers[5].text;
                          //   searchKeywords.addAll(_preferences
                          //       .getControllers[5].text
                          //       .toUpperCase()
                          //       .characters
                          //       .toList());
                          // }
                          // searchKeywords.removeWhere((element) => element == ' ');
                          // searchKeywords = Set.from(searchKeywords).toList();
                          // userInfo['search_keywords'] = searchKeywords;
                        },
                        title: 'Register'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
