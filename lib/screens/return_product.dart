import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/non_inventory_product.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import 'shops.dart';

class ReturnProduct extends StatefulWidget {
  const ReturnProduct({Key? key}) : super(key: key);

  @override
  _ReturnProductState createState() => _ReturnProductState();
}

class _ReturnProductState extends State<ReturnProduct> {
  Uint8List? images;
  String? productImage;
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(FontAwesomeIcons.chevronLeft),
              color: kSubMainColor,
              iconSize: 20.0),
          title: Text(
            'Return Product',
            style: kAppBarTitleTextStyle,
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10.0,
              ),
              imagePickerWidget(
                onTap: () {
                  try {
                    getImageWeb().then((value) {
                      setState(() {
                        images = value.item1;
                        productImage = value.item2;
                      });
                      print('image: $productImage');
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                images: images,
              ),
              SizedBox(
                height: 10.0,
              ),
              textField(
                  controller: controllers[0],
                  prefixIcon:
                      Icon(Icons.person, color: kNewTextColor, size: 20.0),
                  hintText: 'Customer\'s name/Id'),
              SizedBox(
                height: 20.0,
              ),
              textField(
                  controller: controllers[1],
                  prefixIcon:
                      Icon(Icons.inventory_2, color: kNewTextColor, size: 20.0),
                  hintText: 'Product\s name'),
              SizedBox(
                height: 20.0,
              ),
              textField(
                  controller: controllers[2],
                  prefixIcon:
                      Icon(Icons.sell, color: kNewTextColor, size: 20.0),
                  hintText: 'Product\s price'),
              SizedBox(
                height: 20.0,
              ),
              textField(
                  controller: controllers[3],
                  prefixIcon:
                      Icon(Icons.note_alt, color: kNewTextColor, size: 20.0),
                  hintText: 'Reason of return',
                  lines: 3),
              SizedBox(
                height: 20.0,
              ),
              sendButton(title: 'Return', onTap: () {
                if (controllers[0].text != null &&
                    controllers[1].text != null &&
                    controllers[2].text != null &&
                    controllers[3].text != null) {
                  setState(() {
                    isLoading = true;
                  });
                  var data = {
                    'customerId': controllers[0].text,
                    'productName': controllers[1].text,
                    'productPrice': num.parse(controllers[2].text),
                    'reason': controllers[3].text,
                    'image': productImage,
                    'date': Timestamp.now()
                  };
                  print(data);
                    GeneralCrud().makeReturn(data).then((value) {
                      setState(() {
                        isLoading = false;
                      });
                      showMyDialog('Product returned', context);
                      controllers[0].clear();
                      controllers[1].clear();
                      controllers[2].clear();
                      controllers[3].clear();
                    }).onError((error, stackTrace) {
                      setState(() {
                        isLoading = false;
                      });
                      showMyDialog('Error occurred try again', context);
                    });
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    showMyDialog('Fields can\'t be empty', context);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
