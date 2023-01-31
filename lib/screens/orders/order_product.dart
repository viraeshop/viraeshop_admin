import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop/items/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/round_button.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/items/items.dart';

class OrderProduct extends StatefulWidget {
  const OrderProduct(
      {Key? key,
      required this.product,
      this.isWithButton = true,
      this.onLongPress,
      this.index,
      })
      : super(key: key);

  final Map product;
  final bool isWithButton;
  final void Function()? onLongPress;
  final int? index;

  @override
  State<OrderProduct> createState() => _OrderProductState();
}

class _OrderProductState extends State<OrderProduct> {
  bool onChangeQuantity = false;
  bool onEdit = false;
  final box = Hive.box('orderItems');
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    final itemBloc = BlocProvider.of<ItemsBloc>(context);
    return BlocListener<ItemsBloc, ItemState>(
      listener: (context, state) {
        if(state is OnErrorItemsState){
          toast(context: context, title: state.message, color: kRedColor);
        }else if(state is RequestFinishedItemsState){
          toast(context: context, title: 'updated', color: kRedColor);
        }
      },
      child: Container(
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
                              if(onEdit){
                                List item = box.getAt(0);
                                itemBloc.add(
                                  UpdateItemEvent(
                                    token: jWTToken,
                                    path: 'orders',
                                    itemModel: Items.fromJson(
                                        item[widget.index!]),
                                  ),
                                );
                                setState(() {
                                  onEdit = false;
                                });
                              }
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
                                    onPressed: () {
                                      List item = box.getAt(0);
                                      item[widget.index!]['quantity'] += 1;
                                      num totalPrice = box.get('totalPrice') -
                                          item[widget.index!]['productPrice'];
                                      num newPrice = item[widget.index!]
                                              ['unitPrice'] *
                                          item[widget.index!]['quantity'];
                                      item[widget.index!]['productPrice'] =
                                          newPrice;
                                      totalPrice += newPrice;
                                      box.put('totalPrice', totalPrice);
                                      box.putAt(0, item);
                                      setState(() {
                                        onEdit = true;
                                      });
                                    },
                                    icon: Icons.add,
                                    color: kNewMainColor,
                                  ),
                                  RoundButton(
                                    onPressed: () {
                                      List item = box.getAt(0);
                                      if (item[widget.index!]['quantity'] !=
                                          0) {
                                        item[widget.index!]['quantity'] -= 1;
                                        num totalPrice = box.get('totalPrice') -
                                            item[widget.index!]['productPrice'];
                                        num newPrice = item[widget.index!]
                                                ['unitPrice'] *
                                            item[widget.index!]['quantity'];
                                        item[widget.index!]['productPrice'] =
                                            newPrice;
                                        totalPrice += newPrice;
                                        box.put('totalPrice', totalPrice);
                                        box.putAt(0, item);
                                        setState(() {
                                          onEdit = true;
                                        });
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
                        '${widget.product['productName']}',
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
                        '(${widget.product['productId']})',
                        style: const TextStyle(
                          color: kSubMainColor,
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.product['unitPrice'].toString()}৳',
                        style: kTotalTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${widget.product['productPrice'].toString()}৳',
                    style: kTotalTextStyle,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  widget.isWithButton
                      ? IconButton(
                          onPressed: () {
                            List items = box.getAt(0);
                            num price = box.get('totalPrice'),
                                quantity = box.get('totalItems');
                            price -= items[widget.index!]['productPrice'];
                            quantity -= items[widget.index!]['quantity'];
                            items.removeAt(widget.index!);
                            box.putAll({
                              'items': items,
                              'totalPrice': price,
                              'totalItems': quantity,
                            });
                            itemBloc.add(DeleteItemEvent(
                                token: jWTToken,
                                productId: items[widget.index!], path: 'orders'),);
                          },
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
      ),
    );
  }
}
