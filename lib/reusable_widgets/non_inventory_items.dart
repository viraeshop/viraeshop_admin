import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop/suppliers/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'hive/shops_model.dart';

class NonInventoryScreen extends StatefulWidget {
  const NonInventoryScreen({Key? key}) : super(key: key);

  @override
  _NonInventoryScreenState createState() => _NonInventoryScreenState();
}

class _NonInventoryScreenState extends State<NonInventoryScreen> {
  // String userId = Hive.box('userInfo').get('userId');
  TextEditingController _controller = TextEditingController();
  TextEditingController descControl = TextEditingController();
  TextEditingController invoiceController = TextEditingController();
  List<String> nums = [];
  bool isDesc = false;
  String desc = 'Add Description';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: const Text('Sell a non-inventory item', style: kAppBarTitleTextStyle),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              FontAwesomeIcons.chevronLeft,
              color: kSubMainColor,
              size: 20.0,
            ),
          ),
          shape: const Border(
            bottom: BorderSide(color: Colors.black12),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: TextField(
                  cursorColor: kMainColor,
                  style: const TextStyle(
                    color: kMainColor,
                    fontFamily: 'Montserrat',
                    fontSize: 30,
                    letterSpacing: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: kMainColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kMainColor),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: kMainColor, width: 2.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50.0,
              ),
              isDesc == false
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          isDesc = true;
                        });
                      },
                      child: Text(
                        desc,
                        style: const TextStyle(
                          color: kMainColor,
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          letterSpacing: 1.3,
                        ),
                      ),
                    )
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextField(
                        cursorColor: kMainColor,
                        style: const TextStyle(
                          color: kSubMainColor,
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          letterSpacing: 1.3,
                        ),
                        onChanged: (e) {
                          setState(() {
                            desc = e;
                          });
                        },
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.text,
                        controller: descControl,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kMainColor),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kMainColor),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kMainColor, width: 2.0),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.done,
                              color: kSubMainColor,
                              size: 20.0,
                            ),
                            onPressed: () {
                              setState(() {
                                isDesc = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 10.0,
              ),
              TextButton(
                onPressed: () {
                  final jWTToken = Hive.box('adminInfo').get('token');
                  final supplierBloc = BlocProvider.of<SuppliersBloc>(context);
                  supplierBloc.add(GetSuppliersEvent(token: jWTToken));
                  getNonInventoryDialog(buildContext: context, box: 'shops');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: Hive.box('shops').listenable(),
                        builder: (context, Box box, childs) {
                          String shopName =
                              box.get('businessName', defaultValue: 'Suppliers');
                          return Text(
                            shopName,
                            style: kTotalTextStyle,
                          );
                        }),
                    const Icon(
                      FontAwesomeIcons.chevronRight,
                      color: kBlackColor,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: NumericKeyboard(
                  textColor: kSubMainColor,
                  onKeyboardTap: (value) {
                    setState(
                      () {
                        nums.add(value);
                        _controller.text = nums.join();
                      },
                    );
                  },
                  leftButtonFn: () {
                    setState(() {
                      nums.removeLast();
                      _controller.text = nums.join();
                    });
                  },
                  leftIcon: const Icon(
                    Icons.backspace,
                    size: 30.0,
                    color: kSubMainColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 100.0,
              ),
              InkWell(
                onTap: () {
                  Box shopBox = Hive.box('shops');
                  if(shopBox.isNotEmpty){
                    Box box = Hive.box('cartDetails');
                    Random random = Random();
                    Box<Cart> cart = Hive.box<Cart>('cart');
                    Box<Shop> shop = Hive.box<Shop>('shopList');
                    var price = num.parse(_controller.text);
                    int totalItems = box.get('totalItems', defaultValue: 0);
                    var totalPrice = box.get('totalPrice', defaultValue: 0.0);
                    box.put('totalItems', ++totalItems);
                    box.put(
                      'totalPrice',
                      totalPrice + price,
                    );
                    box.put('isAdded', true);
                    int id = random.nextInt(100);
                    cart.put(
                      id,
                      Cart(
                        productName: descControl.text,
                        productId: id.toString(),
                        price: num.parse(_controller.text),
                        quantity: 1,
                        unitPrice: num.parse(_controller.text),
                        isInventory: false,
                        supplierId: shopBox.get('supplierId').toString(),
                      ),
                    );

                    shop
                        .put(
                      id,
                      Shop(
                        supplierId: shopBox.get('supplierId').toString(),
                        name: shopBox.get('businessName'),
                        price: price,
                        address: shopBox.get('address'),
                        email: shopBox.get('email'),
                        mobile: shopBox.get('mobile'),
                        description: descControl.text,
                        buyPrice: 0,
                      ),
                    )
                        .whenComplete(() {
                      shopBox
                          .clear()
                          .whenComplete(() => Navigator.pop(context))
                          .catchError((error) => print(error));
                    }).catchError((error) => print(error));
                  }else{
                    toast(context: context, title: 'Supplier must\'nt be empty', color: kRedColor);
                  }
                },
                child: Container(
                  height: 50.0,
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: kMainColor,
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Send to cart',
                      style: kDrawerTextStyle1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
