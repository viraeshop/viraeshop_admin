import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

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
  num profit = 0;
  int totalQuantity = cartDetails.get('totalItems');
  num discount = cartDetails.get('discountAmount', defaultValue: 0);
  final String adminId =
      Hive.box('adminInfo').get('adminId', defaultValue: 'adminId');
  final String adminName = Hive.box('adminInfo').get('name', defaultValue: '');
  List<Map> transDesc = [];
  String customerId = customerBox.isEmpty ? '' : customerBox.get('id') ?? '';
  String customerRole = customerBox.isEmpty ? '' : customerBox.get('role');
  String invoiceNo = randomNumeric(3);
  @override
  void initState() {
    // TODO: implement initState
    amountReceived = widget.advance != 0 ? widget.advance : widget.paid;
    for (var element in cartItems) {
      if(element.isInventory!){
        profit += element.price - (element.buyPrice * element.quantity);
      }
      Map cartProduct = {
        'product_name': element.productName,
        'product_id': element.productId,
        'product_price': element.price,
        'quantity': element.quantity,
        'unit_price': element.unitPrice,
        'isInventory': element.isInventory,
        'buy_price': element.buyPrice,
      };
      if (element.shopName != '') {
        cartProduct['shopName'] = element.shopName;
      }
      transDesc.add(cartProduct);
      if (element.isInventory == false) {
        isWithNonInventory = true;
      }
    }
    for (var element in shops) {
      shop.add({
        'business_name': element.name,
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
    }
    super.initState();
  }
  bool invoiceNumberTaken = true;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              FontAwesomeIcons.chevronLeft,
            ),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: const Text(
            'Payment: Cash',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: false,
          shape: const Border(
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
                    const Text(
                      'AMOUNT RECEIVED',
                      style: kCategoryNameStyle,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      '${amountReceived.toString()}৳',
                      style: const TextStyle(
                        color: kMainColor,
                        fontFamily: 'Montserrat',
                        fontSize: 30,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
              FractionallySizedBox(
                heightFactor: 0.12,
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () async {
                    if (kDebugMode) {
                      print('Profit: $profit');
                    }
                    Map<String, dynamic> transInfo = {
                      'price': totalPrice - discount,
                      'quantity': totalQuantity.toString(),
                      'date': Timestamp.now(),
                      'employee_id': adminId,
                      'employee_name': adminName,
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
                      'profit': profit,
                      'user_info': {
                        'name': Hive.box('customer').get('name'),
                        'email': Hive.box('customer').get('email'),
                        'address': Hive.box('customer').get('address'),
                        'mobile': Hive.box('customer').get('mobile'),
                        'business_name': Hive.box('customer')
                            .get('business_name', defaultValue: ''),
                        'search_keywords':
                            Hive.box('customer').get('search_keywords'),
                      },
                    };
                    if (isWithNonInventory) {
                      transInfo['shop'] = shop;
                      if (kDebugMode) {
                        print('non-inventory');
                      }
                    }
                    if (kDebugMode) {
                      print('done with map.. now move on to database');
                    }
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      while (invoiceNumberTaken){
                        final invoice = await NetworkUtility.getCustomerTransactionInvoicesByID(invoiceNo);
                        if (kDebugMode) {
                          print('Invoice Taken: ${invoice.exists}');
                        }
                        setState(() {
                          if(!invoice.exists){
                            invoiceNumberTaken = false;
                          }else{
                            invoiceNo = randomNumeric(3);
                            transInfo['invoice_id'] = invoiceNo;
                            transInfo['docId'] = invoiceNo;
                          }
                        });
                      }
                      if (customerRole == 'agents') {
                        num wallet = customerBox.get('wallet', defaultValue: 0);
                        num balanceToPay = totalPrice - discount;
                        if(widget.paid == 0){
                          if (wallet >= balanceToPay) {
                            num balance = wallet - balanceToPay;
                            await NetworkUtility.updateWallet(customerId, {
                              'wallet': balance,
                            });
                            if (kDebugMode) {
                              print('balance: $balance');
                            }
                            customerBox.put('wallet', balance);
                            await NetworkUtility.makeTransaction(
                                invoiceNo, transInfo);
                            await NetworkUtility.updateProducts(cartItems);
                            Future.delayed(const Duration(milliseconds: 0), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return DoneScreen(info: transInfo);
                                }),
                              );
                            });
                          }else{
                            toast(context: context, title: 'Sorry customer has insufficient balance in his account');
                          }
                        }else{
                          await NetworkUtility.makeTransaction(
                              invoiceNo, transInfo);
                          await NetworkUtility.updateProducts(cartItems);
                          Future.delayed(const Duration(milliseconds: 0), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return DoneScreen(info: transInfo);
                              }),
                            );
                          });
                        }
                      } else {
                        await NetworkUtility.makeTransaction(
                            invoiceNo, transInfo);
                        await NetworkUtility.updateProducts(cartItems);
                        Future.delayed(const Duration(milliseconds: 0), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return DoneScreen(info: transInfo);
                            }),
                          );
                        });
                      }
                    } on FirebaseException catch (e) {
                      if (kDebugMode) {
                        print(e.message);
                      }
                      snackBar(
                          text: e.message!,
                          context: context,
                          color: kRedColor,
                          duration: 1000);
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        'Charge BDT ${(totalPrice- discount).toString()}',
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
