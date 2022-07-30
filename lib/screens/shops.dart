import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/non_inventory_product.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

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
  String imageUrl = '';
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
        body: Container(
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
                        getImageWeb().then((value) {
                          setState(() {
                            bundleImage = value.item1!;
                            imageUrl = value.item2!;
                          });
                        });
                      },
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: BoxDecoration(
                          image: imageBG(bundleImage, 'assets/images/man.png'),
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
                            hintText: 'Name of supplier',
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
                            hintText: 'Business name',
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
                            '+88',
                            style: kTableCellStyle,
                          ),
                        ],
                      ),
                    ),
                    hintText: 'Phone',
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
                  hintText: 'Optional Phone',
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
                    hintText: 'Email'),
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
                    hintText: 'Address'),
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
                      AdminCrud().addShop(controllers[1].text, {
                        'supplier_name': controllers[0].text,
                        'business_name': controllers[1].text,
                        'email': controllers[3].text,
                        'mobile': controllers[2].text,
                        'address': controllers[4].text,
                        'profileImage': imageUrl,
                      }).then((value) {
                        setState(() {
                          isLoading = false;
                        });
                      }).catchError((error) {
                        setState(() {
                          isLoading = false;
                        });
                      });
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
