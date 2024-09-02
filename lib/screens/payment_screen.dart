import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:random_string/random_string.dart';
import 'package:viraeshop_bloc/customers/barrel.dart';
import 'package:viraeshop_bloc/transactions/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/utils/utils.dart';

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
  String invoiceNo = generateInvoiceNumber().toString();
  @override
  void initState() {
    // TODO: implement initState
    amountReceived = widget.advance != 0 ? widget.advance : widget.paid;
    for (var element in cartItems) {
      if (element.isInventory) {
        profit += element.price - (element.buyPrice * element.quantity);
      }
      Map cartProduct = {
        'productName': element.productName,
        'productId': element.productId,
        'productPrice': element.price,
        'quantity': element.quantity,
        'unitPrice': element.unitPrice,
        'isInventory': element.isInventory,
        'buyPrice': element.buyPrice,
      };
      if (element.supplierId != '') {
        cartProduct['shopName'] = element.supplierId;
      }
      transDesc.add(cartProduct);
      if (element.isInventory == false) {
        isWithNonInventory = true;
      }
    }
    for (var element in shops) {
      if (!shop.any((item) => element.supplierId == item['supplierId'])) {
        List<Cart> nonInventoryItems = cartItems
            .where((cartItem) =>
                !cartItem.isInventory &&
                element.supplierId == cartItem.supplierId)
            .toList();
        Map<String, dynamic> shopItem = {};
        for (var item in nonInventoryItems) {
          if (shopItem.isNotEmpty) {
            shopItem['supplierId'] = item.supplierId;
            shopItem['price'] += item.price;
            shopItem['buyPrice'] += item.buyPrice;
            shopItem['profit'] += 0;
            shopItem['paid'] += 0;
            shopItem['due'] += 0;
            shopItem['description'] +=
                ' ,${item.productName}(${item.quantity} Items)';
          } else {
            shopItem['supplierId'] = item.supplierId;
            shopItem['price'] = item.price;
            shopItem['buyPrice'] = item.buyPrice;
            shopItem['profit'] = 0;
            shopItem['paid'] = 0;
            shopItem['due'] = 0;
            shopItem['description'] =
                '${item.productName}(${item.quantity} Items)';
          }
        }
        shop.add(shopItem);
      }
    }
    super.initState();
  }

  bool invoiceNumberTaken = true;
  Map<String, dynamic> transInfo = {};
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    final customerBloc = BlocProvider.of<CustomersBloc>(context);
    final transacBloc = BlocProvider.of<TransactionsBloc>(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionsBloc, TransactionState>(
          listener: (context, state) {
            if (state is OnErrorTransactionState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
                duration: 50,
              );
            } else if (state is RequestFinishedTransactionState) {
              setState(() {
                isLoading = false;
              });
              debugPrint(state.response.result.toString());

              ///Todo: Implement product update here also...
              transInfo['invoiceNo'] = state.response.result?['invoiceNo'];
              transInfo['customerInfo'] = {
                'name': Hive.box('customer').get('name'),
                'email': Hive.box('customer').get('email'),
                'address': Hive.box('customer').get('address'),
                'mobile': Hive.box('customer').get('mobile'),
                'businessName':
                    Hive.box('customer').get('businessName', defaultValue: ''),
              };
              Future.delayed(const Duration(milliseconds: 0), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return DoneScreen(info: transInfo);
                  }),
                );
              });
            }
          },
        ),
        BlocListener<CustomersBloc, CustomerState>(listener: (context, state) {
          if (state is OnErrorCustomerState) {
            setState(() {
              isLoading = false;
            });
            snackBar(
              text: state.message,
              context: context,
              color: kRedColor,
              duration: 50,
            );
          } else if (state is RequestFinishedCustomerState) {
            transacBloc.add(AddTransactionEvent(
                token: jWTToken, transactionModel: transInfo));
          }
        })
      ],
      child: ModalProgressHUD(
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
                      setState(() {
                        isLoading = true;
                      });
                      transInfo = {
                        'price': totalPrice - discount,
                        'quantity': totalQuantity.toString(),
                        'createdAt': dateToJson(Timestamp.now()),
                        'adminId': adminId,
                        'items': transDesc,
                        'isWithNonInventory': isWithNonInventory,
                        'customerId': customerId,
                        'role': customerRole,
                        'paid': widget.paid,
                        'due': widget.due,
                        'advance': widget.advance,
                        'discount': discount,
                        'profit': profit,
                      };
                      if (isWithNonInventory) transInfo['shops'] = shop;
                      if (customerRole == 'agents' && widget.paid == 0) {
                        num wallet = customerBox.get('wallet', defaultValue: 0);
                        num balanceToPay = totalPrice - discount;
                        print(wallet);
                        if (wallet >= balanceToPay) {
                          num balance = wallet - balanceToPay;
                          customerBox.put('wallet', balance);
                          customerBloc.add(UpdateCustomerEvent(
                              token: jWTToken,
                              customerId: customerId,
                              customerModel: {
                                'wallet': balance,
                              }));
                        } else {
                          toast(
                            context: context,
                            title:
                                'Sorry customer has insufficient balance in his account',
                          );
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        transacBloc.add(
                          AddTransactionEvent(
                            token: jWTToken,
                            transactionModel: transInfo,
                          ),
                        );
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
                          'Charge BDT ${(totalPrice - discount).toString()}',
                          style: kDrawerTextStyle1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
