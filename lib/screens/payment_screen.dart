import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:random_string/random_string.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import '../reusable_widgets/hive/shops_model.dart';
import 'done_screen.dart';

class PaymentScreen extends StatefulWidget {
  final num paid, due, advance;
  PaymentScreen({required this.paid, required this.due, required this.advance});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = false, isWithNonInventory = false;
  List<Cart> cartItems = Hive.box<Cart>('cart').values.toList();
  List<Shop> shops = Hive.box<Shop>('shopList').values.toList();
  static Box customerBox = Hive.box('customer');
  static final cartDetails = Hive.box('cartDetails');
  List shop = [];
  num totalPrice = cartDetails.get('totalPrice');
  num amountReceived = 0;
  int totalQuantity = cartDetails.get('totalItems');
  num discount = cartDetails.get('discountAmount', defaultValue: 0);
  final String adminId =
      Hive.box('adminInfo').get('adminId', defaultValue: 'adminId');
  List<Map> transDesc = [];
  String customerId =
      customerBox.isEmpty ? '' : customerBox.get('id') == null ? '' : customerBox.get('id');
  String customerRole =
      customerBox.isEmpty ? '' : customerBox.get('role');
  String invoiceNo = randomNumeric(3);
  @override
  void initState() {
    // TODO: implement initState
  amountReceived =  widget.advance != 0 ? widget.advance : widget.paid;
    cartItems.forEach((element) {
      Map cartProduct = {
        'product_name': element.productName,
        'product_id': element.productId,
        'product_price': element.price,
        'quantity': element.quantity,
        'unit_price': element.unitPrice,
        'isInventory': element.isInventory,
      };
      if (element.shopName != '') {
        cartProduct['shopName'] = element.shopName;
      }
      transDesc.add(cartProduct);
      if (element.isInventory == false) {
        isWithNonInventory = true;
      }
    });
    shops.forEach((element) {
      shop.add({
        'name': element.name,
        'address': element.address,
        'mobile': element.mobile,
        'email': element.email,
        'price': element.price,
        'buy_price': element.buyPrice,
        'profit': element.profit,
        'paid': element.paid,
        'due': element.due,
        'images': element.images,
        'pay_list': element.payList,
        'description': element.description,
      });
    });
    super.initState();
  }

  Future updateProducts() async {
    String errorMessage = 'Product Inventory Updated Sucessfully';
    try {
      cartItems.forEach((element) async {
        await updateProductInventory(element.productId, element.quantity)
            .then((value) => print('updated'))
            .catchError((error) {
          errorMessage = error;
        });
      });
    } catch (e) {
      print(e);
      errorMessage = e.toString();
    }
    return errorMessage;
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              FontAwesomeIcons.chevronLeft,
            ),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: Text(
            'Payment: Cash',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: false,
          shape: Border(
            bottom: BorderSide(color: kStrokeColor),
          ),
        ),
        body: Container(
          color: kBackgroundColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                heightFactor: 0.8,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'AMOUNT RECEIVED',
                      style: kCategoryNameStyle,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      '${amountReceived.toString()}৳',
                      style: TextStyle(
                        color: kMainColor,
                        fontFamily: 'Montserrat',
                        fontSize: 30,
                        letterSpacing: 1.3,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
              FractionallySizedBox(
                heightFactor: 0.12,
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {
                    GeneralCrud generalCrud = GeneralCrud();
                    Map<String, dynamic> transInfo = {
                      'price': totalPrice,
                      'quantity': totalQuantity.toString(),
                      'date': Timestamp.now(),
                      'employee_id': adminId,
                      'items': transDesc,
                      'invoice_id': invoiceNo,
                      'isWithNonInventory': isWithNonInventory,
                      'docId': invoiceNo,
                      'customer_id': customerId,
                      'customer_role': customerRole,
                      'paid': widget.paid,
                      'due': widget.due,
                      'advance': widget.advance,
                      'discount': discount,
                      'user_info': {
                        'name': Hive.box('customer').get('name'),
                        'email': Hive.box('customer').get('email'),
                        'address': Hive.box('customer').get('address'),
                        'mobile': Hive.box('customer').get('mobile'),
                      },
                    };
                    if (isWithNonInventory) {
                      transInfo['shop'] = shop;
                      print('non-inventory');
                    }
                    print('done with map.. now move on to database');
                    setState(() {
                      isLoading = true;
                    });
                    generalCrud
                        .makeTransaction(invoiceNo, transInfo)
                        .then((value) {
                      setState(() {
                        isLoading = false;
                      });
                      updateProducts().then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return DoneScreen(info: transInfo);
                          }),
                        );
                      }).catchError((error) {
                        print('Error message $error');
                        setState(() {
                          isLoading = false;
                        });
                      });
                    }).catchError((value) {
                      setState(() {
                        isLoading = false;
                      });
                      showDialogBox(
                          buildContext: context, msg: 'Error occured');
                      print(value);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        'Charge BDT ${totalPrice.toString()}',
                        style: kDrawerTextStyle1,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
