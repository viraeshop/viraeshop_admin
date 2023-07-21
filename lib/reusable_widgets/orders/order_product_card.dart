import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viraeshop/orders/barrel.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/cylindrical_buttons.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/order_chips.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import 'package:viraeshop_admin/screens/orders/order_screen.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_api/models/items/items.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';

import '../../components/styles/colors.dart';
import '../../screens/orders/order_provider.dart';

class OrderProductCard extends StatefulWidget {
  const OrderProductCard({
    Key? key,
    required this.product,
    required this.index,
    this.admins,
    this.onNotOrderStage = true,
  }) : super(key: key);

  final Items product;
  final List<AdminModel>? admins;
  final bool onNotOrderStage;
  final int index;

  @override
  State<OrderProductCard> createState() => _OrderProductCardState();
}

class _OrderProductCardState extends State<OrderProductCard> {
  int quantity = 0;
  String dropdownValue = 'confirmed';
  bool onLocation = false;
  bool onPhone = false;
  bool onSent = false;
  int statusIndex = 0;
  List<AdminModel> admins = [];
  bool onEdit = false;
  bool isLoading = false, onDelete = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    quantity = widget.product.quantity;
    admins = widget.admins ?? [];
    if (widget.onNotOrderStage && admins.isNotEmpty) {
      dropdownValue = admins[0].name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrderState>(
      listener: (context, state) {
        if (state is RequestFinishedOrderItemState) {
          setState(() {
            isLoading = false;
            onEdit = false;
          });
          if(onDelete){
            Provider.of<OrderProvider>(context, listen: false).deleteProduct(widget.index);
            setState(() {
              onDelete = false;
            });
          }
        } else if (state is OnErrorOrderItemState) {
          setState(() {
            isLoading = false;
          });
          snackBar(
              text: state.message,
              context: context,
              color: kRedColor,
              duration: 500);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: BlurryModalProgressHUD(
                inAsyncCall: isLoading,
                dismissible: true,
                //color: kNewMainColor,
                progressIndicator: const Center(
                  child: CircularProgressIndicator(
                    color: kNewMainColor,
                  ),
                ),
                child: Container(
                  height: 200.0,
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        widget.product.productImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OpaqueButton(
                        onTap: () {
                          if (onEdit) {
                            setState(() {
                              isLoading = true;
                            });
                            productUpdate(
                              context: context,
                              data: {
                                'id': widget.product.id,
                                'itemInfo': {
                                  'quantity': quantity,
                                }
                              },
                            );
                          } else {
                            setState(() {
                              onEdit = true;
                            });
                          }
                        },
                        color: kRedColor,
                        icon: !onEdit ? Icons.edit : Icons.done,
                      ),
                      CylindricalButton(
                        quantity: quantity.toString(),
                        onDelete: () {
                          setState(() {
                            isLoading = true;
                            onDelete = true;
                          });
                          final orderBloc = BlocProvider.of<OrdersBloc>(context);
                          orderBloc.add(DeleteOrderItemEvent(
                              orderId: widget.product.id.toString(), token: jWTToken));
                        },
                        onAdd: onEdit ? () {
                          setState(() {
                            ++quantity;
                          });
                        } : null,
                        onReduce: onEdit ? () {
                          setState(() {
                            --quantity;
                          });
                        } : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              widget.product.productSupplier.businessName,
              style: kColoredNameStyle,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product.productName,
                  style: kSansTextStyleSmallBlack,
                ),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.product.originalPrice}$bdtSign',
                      style: const TextStyle(
                        color: kBlackColor,
                        fontFamily: 'SourceSans',
                        fontSize: 15,
                        letterSpacing: 1.3,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      '${widget.product.productPrice}$bdtSign',
                      style: kSansTextStyleBigBlack,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DropdownButton(
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(10.0),
                  dropdownColor: Colors.white,
                  iconEnabledColor: kSubMainColor,
                  items: itemsGen(widget.onNotOrderStage, admins),
                  value: dropdownValue,
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value ?? '';
                      isLoading = true;
                    });
                    if (!widget.onNotOrderStage) {
                      productUpdate(
                        context: context,
                        data: {
                          'id': widget.product.id,
                          'orderInfo': {'availability': value == 'confirmed'},
                        },
                      );
                    }
                  },
                ),
                const SizedBox(
                  width: 10.0,
                ),
                OutlinedIconWidget(
                  onTap: () async {
                    setState(() {
                      onPhone = !onPhone;
                      if (onLocation) onLocation = false;
                    });
                    if (onPhone) {
                      String mobile = widget.product.productSupplier.mobile;
                      final url = Uri.parse('tel:$mobile');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                  iconData: Icons.call,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                if (onPhone)
                  Expanded(
                    child: Text(
                      widget.product.productSupplier.mobile,
                      overflow: TextOverflow.ellipsis,
                      style: kProductNameStylePro,
                      maxLines: 3,
                    ),
                  ),
                const SizedBox(
                  width: 10.0,
                ),
                OutlinedIconWidget(
                  onTap: () {
                    setState(() {
                      onLocation = !onLocation;
                      if (onPhone) onPhone = false;
                    });
                  },
                  iconData: Icons.location_pin,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                if (onLocation && !widget.onNotOrderStage)
                  Expanded(
                    child: Text(
                      widget.product.productSupplier.address,
                      overflow: TextOverflow.ellipsis,
                      style: kProductNameStylePro,
                      maxLines: 3,
                    ),
                  ),
                if (widget.onNotOrderStage)
                  Consumer<OrderProvider>(builder: (context, provider, any) {
                    List<String> status = [];
                    if (provider.currentStage == OrderStages.receiving) {
                      status = ['Confirmed', 'Pending'];
                    } else if (provider.currentStage ==
                        OrderStages.processing) {
                      status = ['Pending', 'Sent'];
                    } else {
                      status = ['Success'];
                    }
                    return OrderChips(
                      title: status[statusIndex],
                      onTap: () {
                        setState(() {
                          if (status.length > 1) {
                            if (status.length - statusIndex == 1) {
                              statusIndex = 0;
                            }
                            if (statusIndex < status.length) {
                              statusIndex += 1;
                            }
                          }
                        });
                        if (status[statusIndex] != 'Success' ||
                            status[statusIndex] != 'Pending') {
                          setState(() {
                            isLoading = true;
                          });
                          productUpdate(
                            context: context,
                            data: {
                              'id': widget.product.id,
                              'orderInfo': {
                                if ((provider.currentStage ==
                                        OrderStages.processing) &&
                                    status[statusIndex] == 'Send')
                                  'adminId': dropdownValue,
                                if (provider.currentStage ==
                                    OrderStages.receiving)
                                  'receivingStatus': status[statusIndex],
                              },
                            },
                          );
                        }
                      },
                      isSelected: onSent,
                    );
                  }),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}

class OutlinedIconWidget extends StatelessWidget {
  const OutlinedIconWidget({
    Key? key,
    required this.iconData,
    this.onTap,
    this.height = 30.0,
    this.width = 30.0,
    this.color = const Color(0xff979797),
    this.borderWidth = 1.0,
  }) : super(key: key);

  final IconData iconData;
  final void Function()? onTap;
  final double? height;
  final double? width;
  final Color color;
  final double borderWidth;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(
              color: color,
              width: borderWidth,
            )),
        child: Icon(
          iconData,
          size: 25.0,
          color: color,
        ),
      ),
    );
  }
}

class DropDownMenuWidget extends StatelessWidget {
  const DropDownMenuWidget({
    Key? key,
    required this.color,
    required this.title,
    required this.icon,
  }) : super(key: key);
  final Color color;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OrderChips(
          title: title,
          onTap: null,
          isSelected: false,
        ),
        Container(
          // height: 40.0,
          // width: 40.0,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.all(7.0),
          child: Align(
            child: Icon(
              icon,
              color: kBackgroundColor,
              size: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}

List<DropdownMenuItem<String>> itemsGen(
    bool onOrderStage, List<AdminModel> suppliers) {
  List<DropdownMenuItem<String>> items = [];
  if (onOrderStage) {
    List<String> titles = ['Confirmed', 'Failed'];
    items = titles.map((e) {
      return DropdownMenuItem(
        value: e.toLowerCase(),
        child: Text(
          e,
          style: TextStyle(
            color: e == 'Failed' ? kRedColor : kNewMainColor,
            fontSize: 20.0,
            fontFamily: 'SourceSans',
            letterSpacing: 1.3,
          ),
        ),
      );
    }).toList();
  } else {
    items = suppliers.map((e) {
      return DropdownMenuItem(
        value: e.adminId,
        child: Text(
          e.name,
          style: const TextStyle(
            color: kNewMainColor,
            fontSize: 20.0,
            fontFamily: 'SourceSans',
            letterSpacing: 1.3,
          ),
        ),
      );
    }).toList();
  }
  return items;
}

void productUpdate(
    {required BuildContext context, required Map<String, dynamic> data}) {
  final jWTToken = Hive.box('adminInfo').get('token');
  final ordersBloc = BlocProvider.of<OrdersBloc>(context);
  ordersBloc.add(
    UpdateOrderItemEvent(
      orderModel: data,
      token: jWTToken,
    ),
  );
}
