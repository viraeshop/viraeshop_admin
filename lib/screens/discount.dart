import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class DiscountScreen extends StatefulWidget {
  final bool isItems;
  final keyStore;
  DiscountScreen({this.isItems = false, this.keyStore = ''});

  @override
  _DiscountScreenState createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _percentController = TextEditingController();
  static Box box = Hive.box('cartDetails');
  num discountAmount = 0.0;
  static num originalTotalPrice = 0;
  num currentTotalPrice = 0;
  num discountPercent = 0;
  String cashHint = '';
  String percentHint = '';
  List numbers = List.generate(11, (index) => index.toString());

  @override
  void initState() {
    // TODO: implement initState
    if (widget.isItems) {
      Cart? item = Hive.box<Cart>('cart').get(widget.keyStore);
      item!.price = item.unitPrice * item.quantity;
      cashHint = item.discountValue.toString();
      percentHint = item.discountPercent.toString();
      originalTotalPrice = item.price;
      currentTotalPrice = originalTotalPrice;
    } else {
      originalTotalPrice = box.get('totalPrice', defaultValue: 0.0) + box.get('discountAmount', defaultValue: 0);
      currentTotalPrice = originalTotalPrice;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
                heightFactor: 0.7,
                alignment: Alignment.topCenter,
                child: Container(
                  color: kStrokeColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Cash Discount',
                            style: TextStyle(
                              color: kSubMainColor,
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              letterSpacing: 1.3,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                                style: kProductNameStyle,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  CurrencyTextInputFormatter(symbol: '৳')
                                ],
                                keyboardType: TextInputType.number,
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: cashHint,
                                  border: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kSubMainColor),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: kMainColor),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: kSubMainColor, width: 2.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  List characters = value.characters
                                      .where((p0) =>
                                          numbers.contains(p0) || p0 == '.')
                                      .toList();
                                  if (kDebugMode) {
                                    print(characters.join());
                                  }
                                  setState(() {
                                    discountAmount =
                                        num.parse(characters.join());
                                    if (discountAmount <= originalTotalPrice) {
                                      currentTotalPrice =
                                          (originalTotalPrice - discountAmount)
                                              .round();
                                      discountPercent = (discountAmount /
                                              originalTotalPrice) *
                                          100;
                                      _percentController.text =
                                          discountPercent.toStringAsFixed(2);
                                    }
                                  });
                                }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50.0),
                      Column(
                        children: [
                          const Text(
                            'Percentage Discount',
                            style: TextStyle(
                              color: kSubMainColor,
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              letterSpacing: 1.3,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                                style: kProductNameStyle,
                                textAlign: TextAlign.center,
                                inputFormatters: [
                                  CurrencyTextInputFormatter(
                                    symbol: '',
                                    decimalDigits: 3,
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                                controller: _percentController,
                                decoration: InputDecoration(
                                  hintText: percentHint,
                                  border: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: kSubMainColor),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: kMainColor),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: kMainColor, width: 2.0),
                                  ),
                                ),
                                onChanged: (value) {
                                  List characters = value.characters
                                      .where((p0) =>
                                          numbers.contains(p0) || p0 == '.')
                                      .toList();
                                  //print(characters.join());
                                  setState(() {
                                    discountPercent =
                                        num.parse(characters.join());
                                    discountAmount =
                                        (discountPercent * originalTotalPrice) /
                                            100.round();
                                    currentTotalPrice =
                                        (originalTotalPrice - discountAmount)
                                            .round();
                                    _controller.text =
                                        discountAmount.toString();
                                  });
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              FractionallySizedBox(
                heightFactor: 0.3,
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  color: kBackgroundColor,
                  child: SingleChildScrollView(
                    child: Column(
                      //fit: StackFit.expand,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text(
                                'New total:',
                                style: TextStyle(
                                  color: kSubMainColor,
                                  fontFamily: 'SourceSans',
                                  fontSize: 17,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                '$currentTotalPrice',
                                style: const TextStyle(
                                  color: kSubMainColor,
                                  fontFamily: 'SourceSans',
                                  fontSize: 30,
                                  letterSpacing: 1.3,
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                '$originalTotalPrice',
                                style: const TextStyle(
                                  color: Colors.black38,
                                  fontFamily: 'SourceSans',
                                  fontSize: 25,
                                  letterSpacing: 1.3,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            onTap: () {
                              num newDiscountAmount = box.get('discountAmount', defaultValue: 0);
                              num newDiscountPercent = box.get('discountPercent', defaultValue: 0);
                              if (widget.isItems) {
                                num totalPrice = box.get('totalPrice');
                                Cart? item =
                                    Hive.box<Cart>('cart').get(widget.keyStore);
                                newDiscountAmount -= item!.discountValue;
                                newDiscountPercent -= item.discountPercent;
                                totalPrice += item.discountValue;
                                item.price -= discountAmount;
                                item.discountPercent = discountPercent;
                                item.discountValue = discountAmount;
                                box.put('totalPrice', totalPrice - discountAmount);
                                box.put('discountAmount', newDiscountAmount + discountAmount);
                                box.put('discountPercent', newDiscountPercent + discountPercent);
                                Hive.box<Cart>('cart')
                                    .put(widget.keyStore, item);
                              }else{
                                box.put('discountAmount', newDiscountAmount + discountAmount);
                                box.put('discountPercent', newDiscountPercent + discountPercent);
                                box.put('totalPrice', originalTotalPrice - discountAmount);
                              }
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              margin: const EdgeInsets.all(10.0),
                              height: 70.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: kMainColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                              child: const Center(
                                child: Text(
                                  'Apply Discount',
                                  style: TextStyle(
                                    color: kMainColor,
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
