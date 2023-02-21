import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:viraeshop_admin/reusable_widgets/shopping_cart.dart';

import 'hive/cart_model.dart';
import 'hive/shops_model.dart';

class QuantityScreen extends StatefulWidget {
  var keyStore;
  QuantityScreen({required this.keyStore});
  @override
  _QuantityScreenState createState() => _QuantityScreenState();
}

class _QuantityScreenState extends State<QuantityScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> nums = [];
  String hint = '';
  @override
  void initState() {
    // TODO: implement initState
    Cart? item = Hive.box<Cart>('cart').get(widget.keyStore);
    setState(() {
      hint = item!.quantity.toString();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text('Quantity', style: kAppBarTitleTextStyle),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quantity:',
            style: kProductNameStylePro,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextField(
              style: kProductNameStyle,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.none,
              controller: _controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: kProductNameStylePro,
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kMainColor),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kMainColor),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kMainColor, width: 2.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return alert(
                    title: 'Remove product',
                    message: 'Are you sure you want to remove this product?',
                    context: context,
                    onTap: () {
                      int totalItems =
                          Hive.box('cartDetails').get('totalItems');
                      if (totalItems > 1) {
                        Cart? item =
                            Hive.box<Cart>('cart').get(widget.keyStore);
                        num totalPrice =
                            Hive.box('cartDetails').get('totalPrice');
                        totalPrice -= item!.price;
                        totalItems -= item.quantity;
                        Hive.box('cartDetails').put('totalPrice', totalPrice);
                        Hive.box('cartDetails').put('totalItems', totalItems);
                        if (item.isInventory == false) {
                          Hive.box<Shop>('shopList')
                              .delete(widget.keyStore);
                        }
                        Hive.box<Cart>('cart')
                            .delete(widget.keyStore)
                            .whenComplete(
                              () => Navigator.pop(context),
                            );
                      } else {
                        Hive.box('cartDetails').clear();
                        Hive.box<Cart>('cart').clear();
                        Hive.box<Shop>('shopList').clear();
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              );
            },
            child: const Text(
              'Remove Product',
              style: TextStyle(
                color: kRedColor,
                fontFamily: 'Montserrat',
                fontSize: 20.0,
                letterSpacing: 1.3,
              ),
            ),
          ),
          const SizedBox(
            height: 50.0,
          ),
          Container(
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
              rightButtonFn: () {
                Box box = Hive.box('cartDetails');
                int quantity = int.parse(_controller.text);
                int totalItems = box.get('totalItems', defaultValue: 0);
                num totalPrice = box.get('totalPrice', defaultValue: 0.0);
                Cart? item = Hive.box<Cart>('cart').get(widget.keyStore);
                totalItems -= item!.quantity;
                totalPrice -= item.price;
                item.quantity = quantity;
                item.price = item.unitPrice * quantity;
                print(item.price);
                box.put('totalPrice', totalPrice + item.price);
                box.put('totalItems', totalItems + quantity);
                Hive.box<Cart>('cart').put(widget.keyStore, item);
                Navigator.pop(context);
              },
              rightIcon: const Icon(
                Icons.done,
                size: 30.0,
                color: kSubMainColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// onPressed: () {
//                         if (Hive.box<Cart>('cart').values.toList().length ==
//                             1) {
//                           Hive.box<Cart>('cart').clear();
//                           Hive.box('cartDetails').clear();
//                         }
//                         Hive.box<Cart>('cart').delete(widget.keyStore);
//                       },