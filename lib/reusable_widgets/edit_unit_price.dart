import 'dart:core';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/home_screen_components/decision_components.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:viraeshop_admin/configs/configs.dart';

import 'hive/cart_model.dart';

class EditUnitPrice extends StatefulWidget {
  var keyStore;
  String name;
  EditUnitPrice({super.key, required this.keyStore, required this.name});
  @override
  _EditUnitPriceState createState() => _EditUnitPriceState();
}

class _EditUnitPriceState extends State<EditUnitPrice> {
  final TextEditingController _controller = TextEditingController();
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
            'Edit unit price',
            style: kProductNameStylePro,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: TextField(
              style: kProductNameStyle,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.none,
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
              rightButtonFn: () {
                num newUnitPrice = num.parse(_controller.text);
                Box box = Hive.box('cartDetails');
                num totalPrice = box.get('totalPrice', defaultValue: 0.0);
                Cart? item = Hive.box<Cart>('cart').get(widget.keyStore);
                totalPrice -= item!.productPrice;
                item.unitPrice = newUnitPrice;
                item.productPrice = item.quantity * newUnitPrice;
                item.discount = item.originalPrice - newUnitPrice;
                item.discountPercent = percent(item.discount, item.originalPrice);
                box.put('totalPrice', totalPrice + item.productPrice);
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
