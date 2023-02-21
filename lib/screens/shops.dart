import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop/suppliers/barrel.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Shops extends StatefulWidget {
  const Shops({Key? key}) : super(key: key);

  @override
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  bool isLoading = false;
  Uint8List bundleImage = Uint8List(0);
  Map<String, dynamic> imageUrlData = {};
  String imagePath = '';
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: const Text(
            'Register Supplier',
            style: kAppBarTitleTextStyle,
          ),
        ),
        body: BlocListener<SuppliersBloc, SupplierState>(
          listenWhen: (context, state){
            if(state is RequestFinishedSupplierState || state is OnErrorSupplierState){
              return true;
            }else{
              return false;
            }
          },
          listener: (context, state) {
            if (state is OnErrorSupplierState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
                duration: 400,
              );
            } else if (state is RequestFinishedSupplierState) {
              setState(() {
                isLoading = false;
              });
              toast(
                context: context,
                title: 'Created',
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15.0),
            height: screenSize.height,
            width: screenSize.width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (kIsWeb) {
                            // getImageWeb('suppliers').then((value) {
                            //   setState(() {
                            //     bundleImage = value.item1!;
                            //     imageUrlData = value.item2!;
                            //   });
                            // });
                          } else {
                            getImageNative('suppliers').then((value) {
                              setState(() {
                                imagePath = value['path'];
                                imageUrlData = value['imageData'];
                              });
                            });
                          }
                        },
                        child: Container(
                          height: 100.0,
                          width: 100.0,
                          decoration: BoxDecoration(
                            image: imageBG(
                              bundleImage,
                              imagePath,
                              'assets/images/man.png',
                            ),
                            color: kBackgroundColor,
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.all(
                              color: kSubMainColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          children: [
                            NewTextField(
                              controller: controllers[0],
                              prefixIcon: const Icon(
                                Icons.person,
                                color: kNewTextColor,
                                size: 20,
                              ),
                              hintText: 'Enter name of supplier',
                              labelText: 'Supplier name',
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            NewTextField(
                              controller: controllers[1],
                              prefixIcon: const Icon(
                                Icons.business,
                                color: kNewTextColor,
                                size: 20,
                              ),
                              hintText: 'Enter business name here',
                              labelText: 'Business name',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  NewTextField(
                    controller: controllers[2],
                    maxLength: 11,
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(10),
                      width: 100.0,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.phone_android,
                            color: kNewTextColor,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            '+880',
                            style: kTableCellStyle,
                          ),
                        ],
                      ),
                    ),
                    hintText: 'Enter mobile number',
                    labelText: 'Phone',
                  ),

                  /// Optional number
                  NewTextField(
                    controller: controllers[3],
                    maxLength: 11,
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(10),
                      width: 100.0,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.phone_android,
                            color: kNewTextColor,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            '+88',
                            style: kTableCellStyle,
                          ),
                        ],
                      ),
                    ),
                    hintText: 'Enter optional Phone',
                    labelText: 'Optional Phone',
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  NewTextField(
                    controller: controllers[4],
                    prefixIcon: const Icon(
                      Icons.email,
                      color: kNewTextColor,
                      size: 20,
                    ),
                    hintText: 'Enter email address',
                    labelText: 'Email',
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  NewTextField(
                    controller: controllers[5],
                    prefixIcon: const Icon(
                      Icons.room,
                      color: kNewTextColor,
                      size: 20,
                    ),
                    hintText: 'Enter your address',
                    labelText: 'Address',
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  sendButton(
                    title: 'Create',
                    onTap: () {
                      if (controllers[0].text != null) {
                        setState(() {
                          isLoading = true;
                        });
                        final supplierBloc =
                            BlocProvider.of<SuppliersBloc>(context);
                        Suppliers supplier = Suppliers.fromJson({
                          'supplierName': controllers[0].text,
                          'businessName': controllers[1].text,
                          'mobile': controllers[2].text,
                          'optionalPhone': controllers[3].text,
                          'email': controllers[4].text,
                          'address': controllers[5].text,
                          'profileImage': imageUrlData['url'] ?? '',
                          'imageKey': imageUrlData['key'] ?? '',
                        });
                        supplierBloc
                            .add(AddSupplierEvent(
                            token: jWTToken,
                            supplierModel: supplier));
                      } else {
                        showMyDialog('Fields can\'t be empty', context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget sendButton(
    {required String title,
    void Function()? onTap,
    double width = double.infinity,
    height = 50.0,
    Color color = kNewTextColor}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color,
      ),
      child: Center(
        child: Text(
          title,
          style: kTableHeadingStyle,
        ),
      ),
    ),
  );
}
