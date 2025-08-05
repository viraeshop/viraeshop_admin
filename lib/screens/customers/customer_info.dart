import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop_bloc/customers/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/dialog_button.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/photoslide_show.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../general_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home_screen.dart';

class CustomerInfoScreen extends StatefulWidget {
  final Map info;
  final bool isNew;
  const CustomerInfoScreen({required this.info, this.isNew = false, Key? key})
      : super(key: key);
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

  bool warningNotification = false;
  @override
  void initState() {
// TODO: implement initState
    userInfo = widget.info;
    warningNotification = userInfo['warningNotification'] ?? false;
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
          TextEditingController(text: userInfo['businessName']);
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
        strings['idFrontImage'] = userInfo['idFrontImage'] ?? '';
        strings['idBackImage'] = userInfo['idBackImage'] ?? '';
      }
    } else if (userInfo['role'] == 'agents') {
      _preferences.addHint = 'Business name';
      _preferences.addControllers =
          TextEditingController(text: userInfo['businessName']);
      _preferences.addIconData = Icons.add_business;
      strings['businessName'] = userInfo['businessName'];
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
      child: BlocListener<CustomersBloc, CustomerState>(
        listener: (context, state) {
          print(state);
          if (state is RequestFinishedCustomerState && isLoading) {
            setState(() {
              isLoading = false;
            });
            toast(context: context, title: 'Updated');
            Navigator.popUntil(context, ModalRoute.withName(HomeScreen.path));
          } else if (state is OnErrorCustomerState && isLoading) {
            setState(() {
              isLoading = false;
            });
            snackBar(text: state.message, context: context, color: kRedColor);
          }
        },
        child: Container(
          color: kBackgroundColor,
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Consumer<GeneralProvider>(builder: (context, user, childs) {
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
                            onTap: i == 1 && !user.isEditUser
                                ? () async {
                                    String number =
                                        _preferences.getControllers[i].text;
                                    final url = Uri.parse('tel:$number');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    }
                                  }
                                : null,
                            lines: i == 3 ? 3 : 1,
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
                  SwitchListTile(
                    title: const Text(
                      'Turn on warning notification',
                      style: kProductNameStylePro,
                    ),
                    value: warningNotification,
                    onChanged: (value) {
                      final customerBloc =
                          BlocProvider.of<CustomersBloc>(context);
                      final jWTToken = Hive.box('adminInfo').get('token');
                      customerBloc.add(
                        UpdateCustomerEvent(
                          token: jWTToken,
                          customerId: widget.info['customerId'],
                          customerModel: {
                            'warningNotification': value,
                          },
                        ),
                      );
                      setState(() {
                        isLoading = true;
                        warningNotification = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  userInfo['role'] == 'agents' && userInfo['binNumber'] != null
                      ? Column(
                          children: [
                            IdImageWidget(
                              height: screenSize.height * 0.23,
                              images: [
                                strings['binImage']!,
                                strings['tinImage']!,
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            IdImageWidget(
                              height: screenSize.height * 0.23,
                              images: [
                                strings['tinImage']!,
                                strings['binImage']!,
                              ],
                            ),
                          ],
                        )
                      : userInfo['role'] == 'architect' &&
                              userInfo['idType'] != null
                          ? Column(
                              children: [
                                IdImageWidget(
                                  height: screenSize.height * 0.23,
                                  images: [
                                    strings['idFrontImage']!,
                                    strings['idBackImage']!,
                                  ],
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                IdImageWidget(
                                  height: screenSize.height * 0.23,
                                  images: [
                                    strings['idBackImage']!,
                                    strings['idFrontImage']!,
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox(),
                  const SizedBox(
                    height: 20.0,
                  ),
                  if (widget.isNew)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DialogButton(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            Map<String, dynamic> fields = {
                              'role': widget.info['newRole'],
                              'isNewRequest': false,
                              'accepted': true,
                              'wallet': 20000,
                            };
                            final customerBloc =
                                BlocProvider.of<CustomersBloc>(context);
                            try {
                              if (widget.info['role'] == 'architect') {
                                await NetworkUtility.deleteImage(
                                    key: widget.info['idFrontImageKey']);
                                await NetworkUtility.deleteImage(
                                    key: widget.info['idBackImageKey']);
                              } else if (widget.info['role'] == 'agents') {
                                await NetworkUtility.deleteImage(
                                    key: widget.info['tinImageKey']);
                                await NetworkUtility.deleteImage(
                                    key: widget.info['binImageKey']);
                              }
                              final jWTToken =
                                  Hive.box('adminInfo').get('token');
                              customerBloc.add(
                                UpdateCustomerEvent(
                                  token: jWTToken,
                                  customerId: widget.info['customerId'],
                                  customerModel: fields,
                                ),
                              );
                            } on FirebaseException catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              if (kDebugMode) {
                                print(e.message);
                              }
                              if (context.mounted) {
                                snackBar(
                                  text: e.message!,
                                  context: context,
                                  color: kRedColor,
                                );
                              }
                            }
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
                                return StatefulBuilder(
                                  builder: (context, setNewState) {
                                    return AlertDialog(
                                      content: const Text(
                                        'Are you sure you want to decline this request?',
                                        style: kProductNameStylePro,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            setNewState(() {
                                              isLoading = true;
                                            });
                                            Map<String, dynamic> fields = {
                                              'isNewRequest': false,
                                              'accepted': false,
                                            };
                                            final customerBloc =
                                                BlocProvider.of<CustomersBloc>(
                                                    context);
                                            Navigator.pop(context);
                                            try {
                                              if (widget.info['role'] ==
                                                  'architect') {
                                                await NetworkUtility
                                                    .deleteImage(
                                                        key: widget.info[
                                                            'idFrontImageKey']);
                                                await NetworkUtility
                                                    .deleteImage(
                                                        key: widget.info[
                                                            'idBackImageKey']);
                                              } else if (widget.info['role'] ==
                                                  'agents') {
                                                await NetworkUtility
                                                    .deleteImage(
                                                        key: widget.info[
                                                            'tinImageKey']);
                                                await NetworkUtility
                                                    .deleteImage(
                                                        key: widget.info[
                                                            'binImageKey']);
                                              }
                                              final jWTToken =
                                                  Hive.box('adminInfo')
                                                      .get('token');
                                              customerBloc.add(
                                                UpdateCustomerEvent(
                                                  token: jWTToken,
                                                  customerId:
                                                      widget.info['customerId'],
                                                  customerModel: fields,
                                                ),
                                              );
                                            } on FirebaseException catch (e) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                              if (kDebugMode) {
                                                print(e.message);
                                              }
                                              if (context.mounted) {
                                                snackBar(
                                                  text: e.message!,
                                                  context: context,
                                                  color: kRedColor,
                                                );
                                              }
                                            }
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
                                  },
                                );
                              },
                            );
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
                  else
                    const SizedBox(),
                  !widget.isNew && user.isEditUser
                      ? DialogButton(
                          onTap: () {
                            final customerBloc =
                                BlocProvider.of<CustomersBloc>(context);
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
                              fields['businessName'] =
                                  _preferences.getControllers[4].text;
                            }
                            final jWTToken = Hive.box('adminInfo').get('token');
                            customerBloc.add(
                              UpdateCustomerEvent(
                                  token: jWTToken,
                                  customerId: widget.info['customerId'],
                                  customerModel: fields),
                            );
                          },
                          title: 'Update',
                          width: double.infinity,
                          radius: 10.0,
                          color: kNewTextColor,
                        )
                      : const SizedBox()
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class IdImageWidget extends StatelessWidget {
  const IdImageWidget({
    super.key,
    required this.height,
    required this.images,
  });

  final double height;
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: kSubMainColor,
        ),
        image: DecorationImage(
          image: CachedNetworkImageProvider(images[0]),
          fit: BoxFit.fill,
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return PhotoSlideShow(images: images);
                },
              ),
            );
          },
          child: const Icon(
            Icons.crop_free,
            color: kNewMainColor,
            size: 30.0,
          ),
        ),
      ),
    );
  }
}
