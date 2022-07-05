import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/non_inventory_transaction_info.dart';
import 'package:viraeshop_admin/screens/shops.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import 'user_transaction_screen.dart';

class NewNonInventoryProduct extends StatefulWidget {
  @override
  _NewNonInventoryProductState createState() => _NewNonInventoryProductState();
}

class _NewNonInventoryProductState extends State<NewNonInventoryProduct> {
  GeneralCrud generalCrud = GeneralCrud();
  List<TextEditingController> controllers = List.generate(9, (index) {
    return TextEditingController();
  });
  Timestamp date = Timestamp.now();
  String? uploadImageString = '';
  String errorMessage = '', invoiceNo = '';
  String? receipt;
  Uint8List? image;
  bool isLoading = false;
  List shopNames = [], shopList = [];
  Map currentShop = {};
  String? dropdownValue;
  num paid = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(
        color: kMainColor,
      ),
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(FontAwesomeIcons.chevronLeft),
              iconSize: 20.0,
              color: kSubMainColor,
            ),
            title: Text(
              'Product expense',
              style: kTextStyle1,
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              //alignment: AlignmentDirectional.topCenter,
              //fit: StackFit.expand,
              children: [
                SizedBox(
                  height: 20.0,
                ),
                receipt == null
                    ? imagePickerWidget(
                        onTap: () {
                          try {
                            getImageWeb().then((value) {
                              setState(() {
                                image = value.item1;
                                uploadImageString = value.item2;
                              });
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        images: image,
                      )
                    : GestureDetector(
                        onTap: () {
                          try {
                            getImageWeb().then((value) {
                              setState(() {
                                image = value.item1;
                                uploadImageString = value.item2;
                                receipt = value.item2!;
                              });
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: receipt!,
                                height: 150.0,
                                width: 150.0,
                                errorWidget: (context, url, childs) {
                                  return Image.asset(
                                    'assets/default.jpg',
                                    height: 150.0,
                                    width: 150.0,
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.add,
                                size: 25.0,
                                color: kStrokeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(
                  height: 20.0,
                ),
                textField(
                    controller: controllers[0],
                    readOnly: false,
                    hint: 'Reference No  ',
                    onSubmitted: (invoiceId) {
                      print(invoiceId);
                      setState(() {
                        isLoading = true;
                        invoiceNo = invoiceId;
                      });
                      generalCrud.searchInvoice(invoiceId).then((value) {
                        setState(() {
                          shopNames.clear();
                          isLoading = false;
                        });
                        date = value.get('date');
                        controllers[0].text = value.get('invoice_id');
                        value.get('shop').forEach((element) {
                          shopNames.add(element['name']);
                        });
                        shopList = value.get('shop');
                        currentShop = shopList[0];
                        dropdownValue = currentShop['name'];
                        receipt = currentShop['images'].isNotEmpty
                            ? currentShop['images'][0]
                            : null;
                        controllers[3].text =
                            currentShop['price'].toString();
                        controllers[4].text =
                            currentShop['buy_price'].toString();
                        controllers[5].text =
                            currentShop['profit'].toString();
                        controllers[6].text = currentShop['due'].toString();
                        controllers[7].text =
                            currentShop['paid'].toString();
                        paid = currentShop['paid'];
                        controllers[8].text = currentShop['description'];
                      }).catchError((error) {
                        setState(() {
                          isLoading = false;
                          errorMessage = error.toString();
                        });
                      });
                    }),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: textField(
                        controller: controllers[1],
                        readOnly: true,
                        hint: 'Shops'
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              color: kBlackColor,
                              width: 3.0,
                            ),
                          ),
                        ),
                        value: dropdownValue,
                        items: shopNames.map((e) {
                          return DropdownMenuItem(
                            child: Text(
                              e,
                              style: kTableCellStyle,
                            ),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          Map shop = {};
                          shopList.forEach((element) {
                            if (element['name'] == value.toString()) {
                              shop = element;
                            }
                          });
                          setState(() {
                            dropdownValue = value.toString();
                            currentShop = shop;
                            receipt = currentShop['images'].isNotEmpty
                                ? currentShop['images'][0]
                                : null;
                            controllers[3].text =
                                currentShop['price'].toString();
                            controllers[4].text =
                                currentShop['buy_price'].toString();
                            controllers[5].text =
                                currentShop['profit'].toString();
                            controllers[6].text =
                                currentShop['due'].toString();
                            controllers[7].text =
                                currentShop['paid'].toString();
                            paid = currentShop['paid'];
                            controllers[8].text =
                                currentShop['description'];
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                textFieldRow(
                    controller1: controllers[2],
                    controller2: controllers[3],
                    readOnly1: true,
                    prefix1: 'Sales Price',
                    prefix2: ''),
                SizedBox(
                  height: 10.0,
                ),
                textFieldRow(
                    controller1: controllers[4],
                    controller2: controllers[5],
                    keyboardType: TextInputType.number,
                    readOnly1: false,
                    readOnly2: true,
                    prefix1: 'Buy Price ',
                    prefix2: 'Profit ',
                    onChange1: (value) {
                      num profit = 0;
                      profit =
                          num.parse(controllers[3].text) - num.parse(value);
                      setState(() {
                        controllers[5].text = profit.toString();
                      });
                    }),
                SizedBox(
                  height: 10.0,
                ),
                textFieldRow(
                    controller1: controllers[6],
                    controller2: controllers[7],
                    keyboardType: TextInputType.number,
                    readOnly1: true,
                    prefix1: 'Due ',
                    prefix2: 'Paid ',
                    onChange2: (value) {
                      num due = 0;
                      due = num.parse(controllers[4].text) -
                          (num.parse(value) +
                             paid);
                      setState(() {
                        controllers[6].text = due.toString();
                      });
                    }),
                // SizedBox(
                //   height: 10.0,
                // ),
                // textField(controller: controllers[10], prefix: 'Qunatity'),
                SizedBox(
                  height: 20.0,
                ),
                textField(controller: controllers[8], lines: 3),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buttons(
                        title: 'Update',
                        width: 150.0,
                        onTap: () {
                          List updatedShopList = [];
                          num totalPaid = 0;
                          shopList.forEach((element) {
                            if (dropdownValue == element['name']) {
                              List imageList = element['images'],
                                  payLists = element['pay_list'];
                              imageList.add(uploadImageString);
                              payLists.add({
                                'paid': num.parse(controllers[7].text),
                                'date': Timestamp.now(),
                              });
                              payLists.forEach((element) {
                                totalPaid += element['paid'];
                              });
                              Map updatedShop = {
                                'name': element['name'],
                                'address': element['address'],
                                'mobile': element['mobile'],
                                'email': element['email'],
                                'price': element['price'],
                                'buy_price': num.parse(controllers[4].text),
                                'profit': num.parse(controllers[5].text),
                                'paid': totalPaid,
                                'due': num.parse(controllers[6].text),
                                'images': imageList,
                                'pay_list': payLists,
                                'description': controllers[8].text,
                              };
                              updatedShopList.add(updatedShop);
                            } else {
                              updatedShopList.add(element);
                            }
                          });
                          print('done making map');
                          setState(() {
                            isLoading = true;
                            controllers[7].text = totalPaid.toString();
                          });
                          generalCrud.updateInvoice(invoiceNo, {
                            'shop': updatedShopList,
                          }).then((value) {
                            setState(() {
                              isLoading = false;
                            });
                            showDialogBox(
                                buildContext: context, msg: 'Updated successfully');
                          }).catchError((error) {
                            setState(() {
                              isLoading = false;
                            });
                            showDialogBox(
                                buildContext: context,
                                msg: 'Error occurred');
                          });
                        }),
                    SizedBox(
                      width: 10.0,
                    ),
                    buttons(
                        title: 'View',
                        width: 150.0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return NonInventoryInfo(
                                data: currentShop,
                                invoiceId: invoiceNo,
                                date: date,
                              );
                            }),
                          );
                        }),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget textFieldRow({
  required TextEditingController controller1,
  keyboardType = TextInputType.text,
  controller2,
  bool? readOnly1,
  bool? readOnly2 = false,
  prefix1,
  prefix2,
  void Function(String)? onChange1,
  void Function(String)? onChange2,
}) {
  return Row(
    children: [
      Expanded(
        child: textField(
          controller: controller1,
          readOnly: readOnly1!,
          keyboardType: keyboardType,
          hint: prefix1,
          onChange: onChange1,
        ),
      ),
      SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: textField(
          readOnly: readOnly2!,
            keyboardType: TextInputType.number,
            controller: controller2, hint: prefix2, onChange: onChange2),
      ),
    ],
  );
}

// ignore: avoid_init_to_null
Widget textField({
  required TextEditingController controller,
  bool readOnly = false,
  int lines = 1,
  String hint = '',
  keyboardType = TextInputType.number,
  void Function(String)? onSubmitted,
  void Function(String)? onChange,
}) {
  return TextField(
    textInputAction: TextInputAction.done,
    controller: controller,
    style: kTableCellStyle,
    readOnly: readOnly,
    keyboardType: keyboardType,
    maxLines: lines,
    decoration: InputDecoration(
      prefixIcon: Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(hint, style: kCustomerCellStyle,),
      ),
      //prefixStyle: kCustomerCellStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: kBlackColor,
          width: 3.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: kBlackColor,
          width: 3.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: kBlackColor,
          width: 3.0,
        ),
      ),
    ),
    onSubmitted: onSubmitted,
    onChanged: onChange,
  );
}
