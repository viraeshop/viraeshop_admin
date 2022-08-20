import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/dialog_button.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../general_provider.dart';

class CustomerInfoScreen extends StatefulWidget {
  final Map info;
  final bool isNew;
  const CustomerInfoScreen({required this.info, this.isNew = false});

  @override
  _CustomerInfoScreenState createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  late UserCredential user;
  final CustomerPreferences _preferences = CustomerPreferences();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, String> strings = {};
  Map userInfo = {};
  @override
  void initState() {
// TODO: implement initState
    userInfo = widget.info;
    print('userId: ${userInfo['userId']}');
    strings['currentEmail'] = userInfo['email'];
    strings['currentName'] = userInfo['name'];
    strings['currentAddress'] = userInfo['address'];
    strings['currentMobile'] = userInfo['mobile'];
    _preferences.getControllers[0].text = userInfo['name'];
    _preferences.getControllers[1].text = userInfo['mobile'];
    _preferences.getControllers[2].text = userInfo['email'];
    _preferences.getControllers[3].text = userInfo['address'];
    if (userInfo['role'] == 'architect') {
      _preferences.addHint = 'Business name';
      _preferences.addControllers =
          TextEditingController(text: userInfo['business_name']);
      _preferences.addIconData = Icons.add_business;
      if (userInfo['idType'] != null) {
        if (userInfo['idType'] == 'IAB') {
          _preferences.addHint = 'IAB ID';
        } else {
          _preferences.addHint = 'BSC ID';
        }
        _preferences.addControllers =
            TextEditingController(text: userInfo['idNumber']);
        _preferences.addIconData = Icons.badge_outlined;
        strings['idImage'] = userInfo['idImage'];
      }
    } else if (userInfo['role'] == 'agents') {
      _preferences.addHint = 'Business name';
      _preferences.addControllers =
          TextEditingController(text: userInfo['business_name']);
      _preferences.addIconData = Icons.add_business;
      strings['business_name'] = userInfo['business_name'];
      if (userInfo['binNumber'] != null) {
        _preferences.addAll(hints: [
          'BIN Number',
          'Trade License Number',
        ], controller: [
          TextEditingController(text: userInfo['binNumber']),
          TextEditingController(text: userInfo['tinNumber']),
        ], icons: [
          Icons.badge_outlined,
          Icons.badge_outlined
        ]);
        strings['binImage'] = userInfo['binImage'];
        strings['tinImage'] = userInfo['tinImage'];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Container(
        color: kBackgroundColor,
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Consumer<GeneralProvider>(
            builder: (context, user, childs) {
              return Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Column(
                    children: List.generate(_preferences.getHint.length, (i) {
                      return Column(
                        children: [
                          NewTextField(
                            onTap: i == 1 && !user.isEditUser ? () async{
                             String number = _preferences.getControllers[i].text;
                             final url = Uri.parse('tel:$number');
                             if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                              }
                            } : null,
                            readOnly: !user.isEditUser,
                            controller: _preferences.getControllers[i],
                            prefixIcon: Icon(
                              _preferences.getIconData[i],
                              color: kNewMainColor,
                              size: 20,
                            ),
                            labelText: _preferences.getHint[i],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  userInfo['role'] == 'agents' && userInfo['binNumber'] != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                height: screenSize.height * 0.23,
                                // width: screenSize.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: kSubMainColor,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: CachedNetworkImage(
                                    imageUrl: strings['binImage']!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                height: screenSize.height * 0.23,
                                // width: screenSize.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: kSubMainColor,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: CachedNetworkImage(
                                    imageUrl: strings['tinImage']!,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : userInfo['role'] == 'architect' &&
                              userInfo['idType'] != null
                          ? Container(
                              height: screenSize.height * 0.23,
                              width: screenSize.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: kSubMainColor,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: CachedNetworkImage(
                                  imageUrl: strings['idImage']!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            )
                          : const SizedBox(),
                  const SizedBox(
                    height: 20.0,
                  ),
                  widget.isNew
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DialogButton(
                              onTap: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                AdminCrud adminCrud = AdminCrud();
                                Map<String, dynamic> fields = {
                                  'name': widget.info['name'],
                                  'mobile': widget.info['mobile'],
                                  'email': widget.info['email'],
                                  'address': widget.info['address'],
                                  'role': widget.info['role'],
                                  'userId': widget.info['userId'],
                                };
                                if (widget.info['role'] == 'architect') {
                                  fields['idType'] = widget.info['idType'];
                                  fields['idNumber'] = widget.info['idNumber'];
                                  fields['idImage'] = widget.info['idImage'];
                                } else {
                                  fields['binNumber'] = widget.info['binNumber'];
                                  fields['tinNumber'] = widget.info['tinNumber'];
                                  fields['binImage'] = widget.info['binImage'];
                                  fields['tinImage'] = widget.info['tinImage'];
                                  fields['wallet'] = widget.info['wallet'];
                                }
                                adminCrud
                                    .addCustomer(widget.info['userId'], fields)
                                    .then((value) {
                                  adminCrud
                                      .deleteCustomerRequest(widget.info['userId'])
                                      .then((value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    showMyDialog(
                                      'Customer account created successfully',
                                      context,
                                    );
                                  }).catchError((error) {
                                    if (kDebugMode) {
                                      print(error);
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                    snackBar(
                                      text: 'Failed please try again.',
                                      context: context,
                                      duration: 10,
                                    );
                                  });
                                }).catchError((error) {
                                  print('Adding customer $error');
                                  setState(() {
                                    isLoading = false;
                                  });
                                  showMyDialog(
                                      'An error occured failed to add customer',
                                      context);
                                });
                              },
                              title: 'Accept',
                              width: double.infinity,
                              radius: 10.0,
                              color: kNewTextColor,
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            DialogButton(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: const Text(
                                          'Are you sure you want to decline this request?',
                                          style: kProductNameStylePro,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              Navigator.pop(context);
                                              AdminCrud adminCrud = AdminCrud();
                                              Map<String, dynamic> fields = {
                                                'name': widget.info['name'],
                                                'mobile': widget.info['mobile'],
                                                'email': widget.info['email'],
                                                'address': widget.info['address'],
                                                'role': 'general',
                                                'userId': widget.info['userId'],
                                              };
                                              adminCrud
                                                  .addCustomer(
                                                      widget.info['userId'], fields)
                                                  .then((value) async {
                                                await adminCrud
                                                    .deleteCustomerRequest(
                                                        widget.info['userId']);
                                                if (widget.info['role'] ==
                                                    'architect') {
                                                  await NetworkUtility.deleteImage(
                                                      widget.info['idImage']);
                                                } else {
                                                  await NetworkUtility.deleteImage(
                                                      widget.info['binImage']);
                                                  await NetworkUtility.deleteImage(
                                                      widget.info['tinImage']);
                                                }
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                showMyDialog(
                                                    'Customer account created successfully',
                                                    context);
                                              }).catchError((error) {
                                                if (kDebugMode) {
                                                  print(
                                                      'Customer Request deleting error: $error');
                                                }
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                showMyDialog(
                                                    'An error occured. failed to change customer to general category. please try again',
                                                    context);
                                              });
                                            },
                                            child: const Text(
                                              'Yes',
                                              style: kProductNameStylePro,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'No',
                                              style: kProductNameStylePro,
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              },
                              title: 'Decline',
                              width: double.infinity,
                              radius: 10.0,
                              color: kBackgroundColor,
                              isBorder: true,
                              borderColor: kNewTextColor,
                            ),
                          ],
                        )
                      : const SizedBox(),
                  !widget.isNew && user.isEditUser
                      ? DialogButton(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            Map<String, dynamic> fields = {
                              'name': _preferences.getControllers[0].text,
                              'mobile': _preferences.getControllers[1].text,
                              'email': _preferences.getControllers[2].text,
                              'address': _preferences.getControllers[3].text,
                            };
                            if (widget.info['role'] != 'general') {
                              fields['business_name'] =
                                  _preferences.getControllers[4].text;
                              fields['business_name'] =
                                  _preferences.getControllers[4].text;
                              List searchKeywords = _preferences
                                  .getControllers[0].text
                                  .toUpperCase()
                                  .characters
                                  .toList();
                              searchKeywords.addAll(_preferences
                                  .getControllers[4].text
                                  .toUpperCase()
                                  .characters
                                  .toList());
                              searchKeywords
                                  .removeWhere((element) => element == ' ');
                              searchKeywords = Set.from(searchKeywords).toList();
                              fields['search_keywords'] = searchKeywords;
                            }
                            try {
                              await NetworkUtility.updateUser(
                                  widget.info['userId'], fields);
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          title: 'Update',
                          width: double.infinity,
                          radius: 10.0,
                          color: kNewTextColor,
                        )
                      : const SizedBox()
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
