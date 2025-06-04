import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/shops/barrel.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/transactions/non_inventory_transaction_info.dart';
import 'package:viraeshop_admin/screens/supplier/shops.dart' hide Shops;
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_api/models/shops/shops.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/utils/utils.dart';

import 'transactions/user_transaction_screen.dart';

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
  Map<String, dynamic> uploadImageString = {};
  String errorMessage = '', invoiceNo = '';
  String? receipt;
  Uint8List? image;
  bool isLoading = false;
  List shopNames = [];
  List<Shops> shopList = [];
  late Shops currentShop;
  String? dropdownValue;
  num paid = 0;
  String imagePath = '';
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopsBloc, ShopsState>(
      listener: (BuildContext context, state) {
        if (state is OnErrorShopState) {
          setState(() {
            isLoading = false;
          });
          snackBar(
            text: state.message,
            context: context,
            color: kRedColor,
            duration: 600,
          );
        } else if (state is FetchedShopsState) {
          final value = state.shops.result;
          setState(() {
            shopNames.clear();
            dropdownValue = '';
            isLoading = false;
            if(value.isNotEmpty){
              date = dateFromJson(value[0].createdAt);
              for (var element in value) {
                  shopNames.add(element.supplierInfo.businessName);
                  shopList.add(element);
              }
              currentShop = shopList[0];
              dropdownValue = currentShop.supplierInfo.businessName;
              receipt = currentShop.images.isNotEmpty
                  ? currentShop.images[0]['imageLink']
                  : null;
              controllers[3].text = currentShop.price.toString();
              controllers[4].text = currentShop.buyPrice.toString();
              controllers[5].text = currentShop.profit.toString();
              controllers[6].text = currentShop.due.toString();
              controllers[7].text = currentShop.paid.toString();
              paid = currentShop.paid;
              controllers[8].text = currentShop.description;
            }
          });
          
        } else if (state is RequestFinishedShopState) {
          setState(() {
            isLoading = false;
          });
          toast(context: context, title: state.response.message);
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: kMainColor,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(FontAwesomeIcons.chevronLeft),
                iconSize: 20.0,
                color: kSubMainColor,
              ),
              title: const Text(
                'Product expense',
                style: kTextStyle1,
              ),
              centerTitle: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                //alignment: AlignmentDirectional.topCenter,
                //fit: StackFit.expand,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  receipt == null
                      ? imagePickerWidget(
                          onTap: () {
                            try {
                              if (kIsWeb) {
                                // getImageWeb('product_expense_images')
                                //     .then((value) {
                                //   setState(() {
                                //     image = value.item1;
                                //     uploadImageString = value.item2;
                                //   });
                                // });
                              } else {
                                getImageNative('product_expense_images')
                                    .then((value) {
                                  setState(() {
                                    imagePath = value['path'];
                                    uploadImageString = value['imageData'];
                                  });
                                });
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                            }
                          },
                          imagePath: imagePath,
                        )
                      : GestureDetector(
                          onTap: () {
                            try {
                              if (kIsWeb) {
                                // getImageWeb('product_expense_images')
                                //     .then((value) {
                                //   setState(() {
                                //     image = value.item1;
                                //     uploadImageString = value.item2;
                                //     receipt = value.item2!;
                                //   });
                                // });
                              } else {
                                getImageNative('product_expense_images')
                                    .then((value) {
                                  setState(() {
                                    imagePath = value['path'];
                                    uploadImageString = value['imageData'];
                                    receipt = value['imageData']['url'];
                                  });
                                });
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
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
                              const Align(
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
                  const SizedBox(
                    height: 20.0,
                  ),
                  textField(
                      controller: controllers[0],
                      readOnly: false,
                      hint: 'Reference No  ',
                      onSubmitted: (invoiceId) {
                        setState(() {
                          isLoading = true;
                          invoiceNo = invoiceId;
                        });
                        final shopsBloc = BlocProvider.of<ShopsBloc>(context);
                        shopsBloc.add(
                          GetShopsEvent(
                            token: jWTToken,
                            invoiceNo: invoiceId,
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: textField(
                            controller: controllers[1],
                            readOnly: true,
                            hint: 'Shops'),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: kBlackColor,
                                width: 3.0,
                              ),
                            ),
                          ),
                          value: dropdownValue,
                          items: shopNames.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: kTableCellStyle,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            String changingShop = value.toString();
                            if (kDebugMode) {
                              print(changingShop);
                            }
                            Shops shop = shopList.firstWhere((element) => changingShop == element.supplierInfo.businessName);
                            setState(() {
                              dropdownValue = value.toString();
                              currentShop = shop;
                              receipt = currentShop.images.isNotEmpty
                                  ? currentShop.images[0]['imageLink']
                                  : null;
                              controllers[3].text =
                                  currentShop.price.toString();
                              controllers[4].text =
                                  currentShop.buyPrice.toString();
                              controllers[5].text =
                                  currentShop.profit.toString();
                              controllers[6].text = currentShop.due.toString();
                              controllers[7].text = currentShop.paid.toString();
                              paid = currentShop.paid;
                              controllers[8].text = currentShop.description;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  textFieldRow(
                      controller1: controllers[2],
                      controller2: controllers[3],
                      readOnly1: true,
                      prefix1: 'Sales Price',
                      prefix2: ''),
                  const SizedBox(
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
                  const SizedBox(
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
                            (num.parse(value) + paid);
                        setState(() {
                          controllers[6].text = due.toString();
                        });
                      }),
                  // SizedBox(
                  //   height: 10.0,
                  // ),
                  // textField(controller: controllers[10], prefix: 'Qunatity'),
                  const SizedBox(
                    height: 20.0,
                  ),
                  textField(controller: controllers[8], lines: 3),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buttons(
                          title: 'Update',
                          width: 150.0,
                          onTap: () {
                            num totalPaid =
                                num.parse(controllers[7].text) + paid;
                            String updatingShopId = '';
                            Map<String, dynamic> updatedShop = {};
                            for (var element in shopList) {
                              if (dropdownValue ==
                                  element.supplierInfo.businessName) {
                                updatingShopId = element.shopId!;
                                Map<String, dynamic> imageList = {
                                      'imageLink': uploadImageString['url'],
                                      'imageKey': uploadImageString['key'],
                                      'shopId': element.shopId
                                    },
                                    payLists = {
                                      'invoiceNo': invoiceNo,
                                      'isSupplier': true,
                                      'shopId': element.shopId,
                                      'paid': num.parse(controllers[7].text),
                                      'createdAt': dateToJson(Timestamp.now()),
                                      'updatedAt': dateToJson(Timestamp.now()),
                                    };
                                updatedShop = {
                                  'price': element.price,
                                  'buyPrice': num.parse(controllers[4].text),
                                  'profit': num.parse(controllers[5].text),
                                  'paid': num.parse(controllers[7].text),
                                  'due': num.parse(controllers[6].text),
                                  'images': imageList,
                                  'paylist': payLists,
                                  'description': controllers[8].text,
                                };
                              }
                            }
                            setState(() {
                              isLoading = true;
                              controllers[7].text = totalPaid.toString();
                            });
                            final shopsBloc =
                                BlocProvider.of<ShopsBloc>(context);
                            shopsBloc.add(UpdateShopEvent(
                              token: jWTToken,
                                shopId: updatingShopId,
                                shopModel: updatedShop));
                          }),
                      const SizedBox(
                        width: 10.0,
                      ),
                      buttons(
                        title: 'View',
                        width: 150.0,
                        onTap: () {
                          if (kDebugMode) {
                            print('Current Shop(2): $currentShop');
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return NonInventoryInfo(
                                data: currentShop.toJson(),
                                invoiceId: invoiceNo,
                                date: date,
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
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
      const SizedBox(
        width: 10.0,
      ),
      Expanded(
        child: textField(
            readOnly: readOnly2!,
            keyboardType: TextInputType.number,
            controller: controller2,
            hint: prefix2,
            onChange: onChange2),
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
        padding: const EdgeInsets.all(10.0),
        child: Text(
          hint,
          style: kCustomerCellStyle,
        ),
      ),
      //prefixStyle: kCustomerCellStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: kBlackColor,
          width: 3.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: kBlackColor,
          width: 3.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: kBlackColor,
          width: 3.0,
        ),
      ),
    ),
    onSubmitted: onSubmitted,
    onChanged: onChange,
  );
}
