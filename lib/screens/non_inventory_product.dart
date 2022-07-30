import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/user_transaction_screen.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class NonInventoryProduct extends StatefulWidget {
  final Map data;
  NonInventoryProduct({required this.data});

  @override
  _NonInventoryProductState createState() => _NonInventoryProductState();
}

class _NonInventoryProductState extends State<NonInventoryProduct> {
  List<TextEditingController> controllers = List.generate(10, (index) {
    if (index == 1) {
      return TextEditingController(text: 'Shop');
    } else if (index == 3) {
      return TextEditingController(text: 'Sales price');
    }
    return TextEditingController();
  });
  List<Map> payList = [];
  List<String> images = [];
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      images = widget.data['images'];
      payList = widget.data['pay_list'];
    });
    super.initState();
  }

  String? receiptImage = '';
  Uint8List? image;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    controllers[0].text = widget.data['invoice_id'];
    controllers[2].text = widget.data['user_info']['name'];
    controllers[4].text = widget.data['price'].toString();
    controllers[5].text = widget.data['buy_price'].toString();
    controllers[6].text = widget.data['profit'].toString();
    controllers[7].text = widget.data['due'].toString();
    controllers[8].text = widget.data['paid'].toString();
    controllers[9].text = widget.data['description'];
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 0.3,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    imagePickerWidget(
              onTap: () {
                try {
                  getImageWeb().then((value) {
                    setState(() {
                      image = value.item1;
                      receiptImage = value.item2;
                    });
                  });
                } catch (e) {
                  print(e);
                }
              },
              images: image,
            ),
                  ],
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: 0.7,
                child: Column(
                  children: [
                    textField(
                        controller: controllers[0],
                        readOnly: true,
                        prefix: 'Reference No'),
                    const SizedBox(
                      height: 10.0,
                    ),
                    textFieldRow(
                        controllers[1], controllers[2], true, '', ''),
                    const SizedBox(
                      height: 10.0,
                    ),
                    textFieldRow(controllers[3], controllers[4], true,
                        '', ''),
                    const SizedBox(
                      height: 10.0,
                    ),
                    textFieldRow(controllers[5], controllers[6], false,
                        'Buy Price', 'Profit'),
                    const SizedBox(
                      height: 10.0,
                    ),
                    textFieldRow(
                        controllers[7], controllers[8], false, 'Due', 'Paid'),
                    const SizedBox(
                      height: 10.0,
                    ),
                    textField(controller: controllers[9], lines: 3),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buttons(
                          title: 'Update',
                          width: 100.0,
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            payList.add({
                              'date': Timestamp.now(),
                              'paid': num.parse(controllers[8].text),
                            });
                            images.add(receiptImage!);
                            AdminCrud()
                                .updateNonInventory(widget.data['invoice_no'], {
                              'images': images,
                              'pay_list': payList,
                            }).then((value) {
                              setState(() {
                                isLoading = false;
                              });
                            }).catchError((error) {
                              setState(() {
                                isLoading = false;
                              });
                            });
                          },
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        buttons(title: 'View', width: 100.0),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget textFieldRow(TextEditingController controller1, controller2,
    bool readOnly, String prefix1, prefix2) {
  return Row(
    children: [
      Expanded(
        child: textField(
            controller: controller1, readOnly: readOnly, prefix: prefix1),
      ),
      const SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: textField(controller: controller2, prefix: prefix2),
      ),
    ],
  );
}

// ignore: avoid_init_to_null
Widget textField(
    {required TextEditingController controller,
    bool readOnly = false,
    int lines = 1,
    var prefix = null,
    prefixIcon = null,
    String hintText = ''}) {
  return TextField(
    controller: controller,
    style: kTableCellStyle,
    readOnly: readOnly,
    maxLines: lines,
    decoration: InputDecoration(
      prefixStyle: kTableCellStyle,
      prefixText: prefix,
      prefixIcon: prefixIcon,
      hintText: hintText,
      hintStyle: kTableCellStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: kBlackColor,
          width: 3.0,
        ),
      ),
    ),
  );
}
