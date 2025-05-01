import 'dart:core';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';

import 'hive/cart_model.dart';

class EditUnitPrice extends StatefulWidget {
  var keyStore;
  String name;
  EditUnitPrice({required this.keyStore, required this.name});
  @override
  _EditUnitPriceState createState() => _EditUnitPriceState();
}

class _EditUnitPriceState extends State<EditUnitPrice> {
  TextEditingController _controller = TextEditingController();
  List<String> nums = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(widget.name, style: kAppBarTitleTextStyle),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            FontAwesomeIcons.chevronLeft,
            color: kSubMainColor,
            size: 20.0,
          ),
        ),
        shape: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Edit unit price',
              style: kProductNameStylePro,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextField(
                style: kProductNameStyle,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.none,
                controller: _controller,
                decoration: InputDecoration(
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
            SizedBox(
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
                leftIcon: Icon(
                  Icons.backspace,
                  size: 30.0,
                  color: kSubMainColor,
                ),
                rightButtonFn: () {
                  num newUnitPrice = num.parse(_controller.text);
                  Box box = Hive.box('cartDetails');
                  num totalPrice = box.get('totalPrice', defaultValue: 0.0);
                  Cart? item = Hive.box<Cart>('cart').get(widget.keyStore);
                  totalPrice -= item!.productPrice;
                  item.unitPrice = newUnitPrice;
                  item.productPrice = item.quantity * newUnitPrice;
                  box.put('totalPrice', totalPrice + item.productPrice);
                  Hive.box<Cart>('cart').put(widget.keyStore, item);                  
                  Navigator.pop(context);                  
                },
                rightIcon: Icon(
                  Icons.done,
                  size: 30.0,
                  color: kSubMainColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
