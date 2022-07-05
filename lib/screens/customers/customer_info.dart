import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/dialog_button.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class CustomerInfoScreen extends StatefulWidget {
  final Map<String, dynamic> info;
  bool isNew;
  CustomerInfoScreen({required this.info, this.isNew = false});

  @override
  _CustomerInfoScreenState createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends State<CustomerInfoScreen> {
  late UserCredential user;
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());
  List<String> hintTexts = [
    'Name',
    'Mobile',
    'Email',
    'Address',
  ];
  List<IconData> iconData = [
    Icons.person,
    Icons.phone_android,
    Icons.email,
    Icons.room,
  ];
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
    controllers[0].text = userInfo['name'];
    controllers[1].text = userInfo['mobile'];
    controllers[2].text = userInfo['email'];
    controllers[3].text = userInfo['address'];
    if (userInfo['role'] == 'architect') {
      if (userInfo['idType'] == 'IAB') {
        hintTexts.add(
          'IAB ID',
        );
      } else {
        hintTexts.add('BSC ID');
      }
      controllers.add(
        TextEditingController(text: userInfo['idNumber']),
      );
      iconData.add(Icons.badge_outlined);
      strings['idImage'] = userInfo['idImage'];
    } else if (userInfo['role'] == 'agents') {
      hintTexts.addAll([
        'BIN Number',
        'Trade License Number',
      ]);
      iconData.addAll([Icons.badge_outlined, Icons.badge_outlined]);
      controllers.addAll([
        TextEditingController(text: userInfo['binNumber']),
        TextEditingController(text: userInfo['tinNumber']),
      ]);
      strings['binImage'] = userInfo['binImage'];
      strings['tinImage'] = userInfo['tinImage'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(color: kMainColor,),
      child: Container(
        color: kBackgroundColor,
        padding: EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              Column(
                children: List.generate(hintTexts.length, (i) {
                  return Column(
                    children: [
                      NewTextField(
                        controller: controllers[i],
                        prefixIcon: Icon(
                          iconData[i],
                          color: kNewTextColor,
                          size: 20,
                        ),
                        labelText: hintTexts[i],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(
                height: 20.0,
              ),
              userInfo['role'] == 'agents'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(10.0),
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
                            margin: EdgeInsets.all(10.0),
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
                  : userInfo['role'] == 'architect'
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
                      : SizedBox(),
              SizedBox(
                height: 20.0,
              ),
              widget.isNew == true
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
                                print(error);
                                setState(() {
                                  isLoading = false;
                                });
                                snackBar(text: 'Failed please try again.', context: context,
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
                        SizedBox(
                          height: 15.0,
                        ),
                        DialogButton(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text(
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
                                              await deleteImage(
                                                  widget.info['idImage']);
                                            } else {
                                              await deleteImage(
                                                  widget.info['binImage']);
                                              await deleteImage(
                                                  widget.info['tinImage']);
                                            }
                                            setState(() {
                                              isLoading = false;
                                            });
                                            showMyDialog(
                                                'Customer account created successfully',
                                                context);
                                          }).catchError((error) {
                                            print(
                                                'Customer Request deleting error: $error');
                                            setState(() {
                                              isLoading = false;
                                            });
                                            showMyDialog(
                                                'An error occured. failed to change customer to general category. please try again',
                                                context);
                                          });
                                        },
                                        child: Text(
                                          'Yes',
                                          style: kProductNameStylePro,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
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
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
