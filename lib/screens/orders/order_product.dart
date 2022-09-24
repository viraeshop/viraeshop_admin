import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/round_button.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';

class OrderProduct extends StatefulWidget {
  const OrderProduct(
      {Key? key,
      required this.product,
      this.isWithButton = true,
      this.onLongPress,
      this.index,
      this.onPress})
      : super(key: key);

  final Map product;
  final void Function()? onPress;
  final bool isWithButton;
  final void Function()? onLongPress;
  final int? index;

  @override
  State<OrderProduct> createState() => _OrderProductState();
}

class _OrderProductState extends State<OrderProduct> {
  bool onChangeQuantity = false;
  final box = Hive.box('orderItems');
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      //height: 60.0,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: kStrokeColor,
          ),
        ),
      ),
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                onChangeQuantity = !onChangeQuantity;
                              });
                            },
                            icon: const Icon(Icons.inventory_2_outlined),
                            color: kBlueColor,
                            iconSize: 25.0,
                          ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Text(
                          '${widget.product['quantity'].toString()} X',
                          style: kProductNameStylePro,
                        ),
                      ],
                    ),
                    if (widget.isWithButton)
                      onChangeQuantity
                            ? Row(
                                children: [
                                  RoundButton(
                                    onPressed: (){
                                      List item = box.getAt(0);
                                      item[widget.index!]['quantity'] += 1;
                                      num totalPrice = box.get('totalPrice') - item[widget.index!]['product_price'];
                                      num newPrice = item[widget.index!]['unit_price'] * item[widget.index!]['quantity'];
                                      item[widget.index!]['product_price'] = newPrice;
                                      totalPrice += newPrice;
                                      box.put('totalPrice', totalPrice);
                                      box.putAt(0, item);
                                    },
                                    icon: Icons.add,
                                    color: kNewMainColor,
                                  ),
                                  RoundButton(
                                    onPressed: (){
                                      List item = box.getAt(0);
                                      if(item[widget.index!]['quantity'] != 0){
                                        item[widget.index!]['quantity'] -= 1;
                                        num totalPrice = box.get('totalPrice') - item[widget.index!]['product_price'];
                                        num newPrice = item[widget.index!]['unit_price'] * item[widget.index!]['quantity'];
                                        item[widget.index!]['product_price'] = newPrice;
                                        totalPrice += newPrice;
                                        box.put('totalPrice', totalPrice);
                                        box.putAt(0, item);
                                      }
                                    },
                                    icon: Icons.remove,
                                    color: kNewMainColor,
                                  ),
                                ],
                              )
                            : const SizedBox(),
                  ],
                ),
                const SizedBox(
                  width: 7.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.product['product_name']}',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kSubMainColor,
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${widget.product['product_id']})',
                      style: const TextStyle(
                        color: kSubMainColor,
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.product['unit_price'].toString()}৳',
                      style: kTotalTextStyle,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${widget.product['product_price'].toString()}৳',
                  style: kTotalTextStyle,
                ),
                const SizedBox(
                  width: 5.0,
                ),
                widget.isWithButton
                    ? IconButton(
                        onPressed: widget.onPress,
                        icon: const Icon(Icons.delete),
                        color: kRedColor,
                        iconSize: 25.0,
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

