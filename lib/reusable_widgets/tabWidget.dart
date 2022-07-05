import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';
import 'package:viraeshop_admin/reusable_widgets/non_inventory_items.dart';
import 'package:viraeshop_admin/reusable_widgets/popWidget.dart';
import 'package:viraeshop_admin/reusable_widgets/shopping_cart.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/new_product_screen.dart';

import '../screens/advert/ads_provider.dart';
import 'category/categories.dart';
extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final matrix = renderObject?.getTransformTo(null);

    if (matrix != null && renderObject?.paintBounds != null) {
      final rect = MatrixUtils.transformRect(matrix, renderObject!.paintBounds);
      return rect;
    } else {
      return null;
    }
  }
}
class TabWidget extends StatefulWidget {
  final String category;
  final bool isAll;
  TabWidget({this.category = '', this.isAll = true});
  @override
  _TabWidgetState createState() => _TabWidgetState();
}

class _TabWidgetState extends State<TabWidget> {
  bool isSearch = false;
  bool showSearch = false;
  static List products = Hive.box(productsBox).get(productsKey);
  static List productsList = [];
  List tempStore = [];
  bool addedToCart = false;
  String dropdownValue = 'general';
  double aspectRatio = 0.0, childAspectRatio = 0.0;
  int crossAxisCount = 3;
  final globalKey = GlobalKey();
  List<GlobalKey> globalKeys = List.generate(productsList.isEmpty ? products.length : productsList.length, (index) => GlobalKey());
  OverlayEntry? entry;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((c) {
      // Get the location of the "shopping cart"
      // _endOffset = (_key.currentContext!.findRenderObject() as RenderBox)
      //     .localToGlobal(Offset.zero);
    });
  }
  void showOverlay(Offset offset, int index, String url) {
    entry = OverlayEntry(builder: (context) {
      return Consumer<AdsProvider>(builder: (context, animation, childs) {
        print('show overlay $index');
        final size = MediaQuery.of(context).size.height;
        return AnimatedPositioned(
            height: animation.addedToCart[index] && animation.isStarted ? 0 : 100.0,
            width: animation.addedToCart[index] && animation.isStarted ? 0 : 150.0,
            left: offset.dx,
            bottom: animation.addedToCart[index] ? 0 :  (size - (offset.dy.round() + (offset.dy.round()/2))).round().toDouble(),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    '$url',
                  ),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            duration: Duration(milliseconds: 200));
      });
    });
    final overlay = Overlay.of(context);
    overlay!.insert(entry!);
  }

  void unShowOverlay() {
    setState(() {
      entry!.remove();
      entry = null;
    });
  }
  Offset calculateWidgetPosition(GlobalKey? key) {
    Offset? offset = Offset(0, 0);
    final RenderBox? box =
    key!.currentContext?.findRenderObject() as RenderBox?;
    //print('Render Box: $box');
    offset = box?.localToGlobal(Offset.zero);
    print(offset);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   print(key!.currentContext);
    //   final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    //   print('Render Box: $box');
    //   offset = box?.localToGlobal(Offset.zero);
    //   //print(offset);
    // });
    return offset!;
  }
  void cartAnimation(){
    setState((){
      addedToCart = true;
    });
    Future.delayed(Duration(milliseconds: 200), (){
      setState((){
        addedToCart = false;
      });
    });
  }
  void cartMotionAnimation(int index) {
    Provider.of<AdsProvider>(context, listen: false)
        .animationTrigger(true, index);
    Future.delayed(
      Duration(milliseconds: 200),
          () {
        unShowOverlay();
        Provider.of<AdsProvider>(context, listen: false)
            .animationTrigger(false, index);
        Provider.of<AdsProvider>(context, listen: false)
            .animationTracker(false);
      },
    );
    // Future.delayed(Duration(milliseconds: 200), (){
    //   unShowOverlay();
    // });
  }
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (deviceSize.width <= 480) {
      // mobile screen sizes
      aspectRatio = 3/1.90;
      childAspectRatio = 1;
      crossAxisCount = 3;
    } else if (deviceSize.width > 480 && deviceSize.width <= 768) {
      // Ipads/ Tablets screens
      aspectRatio = 16.0 / 10.0;
      childAspectRatio = 16 / 15.5;
      crossAxisCount = 4;
    } else if (deviceSize.width > 768 && deviceSize.width <= 1024) {
      // Small screens and Laptops
      aspectRatio = 16.0 / 8.8;
      childAspectRatio = 16 / 14.5;
      crossAxisCount = 5;
    } else if (deviceSize.width > 1024) {
      // Desktops and Large Screens
      aspectRatio = 16.0 / 8.8;
      childAspectRatio = 16 / 12.5;
      crossAxisCount = 5;
    }
    return Container(
      color: kBackgroundColor,
      child: Stack(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.start,
        fit: StackFit.expand,
        children: [
          // SizedBox(
          //   height: 10.0,
          // ),
          FractionallySizedBox(
            heightFactor: 0.9,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                ValueListenableBuilder(
                    valueListenable: Hive.box(productsBox).listenable(),
                    builder: (context, Box box, widgets) {
                      List catgs = box.get(catKey);
                      return Categories(
                        catLength: catgs.length + 1,
                        categories: catgs,
                      );
                    }),
                Container(
                  height: 35.0,
                  // width: double.infinity,
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButton(
                        value: dropdownValue,
                        items: [
                          DropdownMenuItem(
                            value: 'general',
                            child: Text(
                              'General',
                              style: kProductNameStylePro,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'agents',
                            child: Text(
                              'Agents',
                              style: kProductNameStylePro,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'architect',
                            child: Text(
                              'Architect',
                              style: kProductNameStylePro,
                            ),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                      ),
                      InkWell(
                        key: globalKey,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return NonInventoryScreen();
                            }),
                          );
                        },
                        child: ImageIcon(
                          AssetImage('assets/icons/flash.png'),
                          color: kSubMainColor,
                          size: 25.0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Consumer<AdsProvider>(builder: (consumerContext, ads, childs) {
                  if (widget.isAll) {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      if(!ads.isSearch && !ads.isStarted){
                        ads.updateProductList(products);
                        List<bool> booleans = List.generate(products.length, (index) => false);
                        ads.updateAddedToCart(booleans);
                      }
                    });
                  } else {
                    List classifiedProducts = products.where((element) {
                      return element['category'] == widget.category;
                    }).toList();
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      if(!ads.isSearch){
                        ads.updateProductList(classifiedProducts);
                        List<bool> booleans = List.generate(classifiedProducts.length, (index) => false);
                        ads.updateAddedToCart(booleans);
                      }
                    });
                  }
                  productsList = ads.products;
                  return Container(
                    padding: EdgeInsets.all(10.0),
                    height: MediaQuery.of(context).size.height * 0.51,
                    child: GridView.builder(
                      // physics:
                      //     ScrollableScrollPhysics(),
                      shrinkWrap: true,
                      // maxRowCount: 3,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // crossAxisExtent: MediaQuery.of(context).size.width /
                        //     MediaQuery.of(context).size.height *
                        //     170,
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                      ),
                      itemCount: productsList.length + 1,
                      itemBuilder: (gridContext, index) {
                        if (index == 0) {
                          final bool isProduct =
                          Hive.box('adminInfo').get('isProducts');
                          return InkWell(
                            onTap: isProduct == false
                                ? null
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewProduct(),
                                ),
                              );
                            },
                            child: LayoutBuilder(
                              builder: (context, constraints) => Container(
                                decoration: BoxDecoration(
                                  color: kMainColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                    child: Icon(
                                      FontAwesomeIcons.plus,
                                      size: 50.0,
                                      color: kBackgroundColor,
                                    )),
                              ),
                            ),
                          );
                        }
                        List images = productsList[index - 1]['image'];
                        num currentPrice = 0;
                        Tuple3<num, num, bool> discountData =
                        Tuple3<num, num, bool>(0, 0, false);
                        if (dropdownValue == 'general') {
                          currentPrice = productsList[index - 1]['generalPrice'];
                          bool isDiscount =
                          productsList[index - 1]['isGeneralDiscount'];
                          if (isDiscount) {
                            num discountPercent = percent(
                                productsList[index - 1]['generalDiscount'],
                                productsList[index - 1]['generalPrice']);
                            num discountPrice = productsList[index - 1]
                            ['generalPrice'] -
                                productsList[index - 1]['generalDiscount'];
                            discountData = Tuple3<num, num, bool>(
                                discountPrice, discountPercent, isDiscount);
                          }
                        } else if (dropdownValue == 'agents') {
                          currentPrice = productsList[index - 1]['agentsPrice'];
                          bool isDiscount =
                          productsList[index - 1]['isAgentDiscount'];
                          if (isDiscount) {
                            num discountPercent = percent(
                                productsList[index - 1]['agentsDiscount'],
                                currentPrice);
                            num discountPrice = currentPrice -
                                productsList[index - 1]['agentsDiscount'];
                            discountData = Tuple3<num, num, bool>(
                                discountPrice, discountPercent, isDiscount);
                          }
                        } else {
                          currentPrice =
                          productsList[index - 1]['architectPrice'];
                          bool isDiscount =
                          productsList[index - 1]['isArchitectDiscount'];
                          if (isDiscount) {
                            num discountPercent = percent(
                                productsList[index - 1]['architectDiscount'],
                                currentPrice);
                            num discountPrice = currentPrice -
                                productsList[index - 1]['architectDiscount'];
                            discountData = Tuple3<num, num, bool>(
                                discountPrice, discountPercent, isDiscount);
                          }
                        }
                        return InkWell(
                          key: globalKeys[index-1],
                              onLongPress: () {
                                print('longggg hawwa\'u i love you');
                                showDialog<void>(
                                  context: context,
                                  // barrierColor: Colors.transparent,
                                  builder: (context) => popWidget(
                                    image: productsList[index - 1]['image'],
                                    productName: productsList[index - 1]['name'],
                                    price: currentPrice.toString(),
                                    description: productsList[index - 1]
                                    ['description'],
                                    category: productsList[index - 1]['category'],
                                    quantity: productsList[index - 1]['quantity']
                                        .toString(),
                                    context: context,
                                    info: productsList[index - 1],
                                    routeName: HomeScreen.path,
                                    isDiscount: discountData.item3,
                                    discountPrice: discountData.item1,
                                    sellBy: productsList[index - 1]['sell_by'],
                                  ),
                                );
                              },
                              onTap: () {
                            print('start');
                            if (!ads.isStarted) {
                              cartAnimation();
                              ads.animationTracker(true);
                              Offset offset = calculateWidgetPosition(globalKeys[index-1]);
                              showOverlay(offset, index-1, '${images.isNotEmpty ? images[0] : ''}');
                              Future.delayed(Duration(milliseconds: 20), () {
                                cartMotionAnimation(index-1);
                              });
                            }
                                Box cartDetailsBox = Hive.box('cartDetails');
                                num price = discountData.item3
                                    ? discountData.item1
                                    : currentPrice;
                                int totalItems =
                                cartDetailsBox.get('totalItems', defaultValue: 0);
                                num totalPrice =
                                cartDetailsBox.get('totalPrice', defaultValue: 0.0);
                                cartDetailsBox.put('totalItems', ++totalItems);
                                cartDetailsBox.put(
                                  'totalPrice',
                                  totalPrice + price,
                                );
                                // print('keys: ${Hive.box<Cart>('cart').keys}');
                                cartDetailsBox.put('isAdded', true);
                                List<Cart> cart =
                                Hive.box<Cart>('cart').values.toList();
                                List<String> keys = [];
                                cart.forEach((element) {
                                  keys.add(element.productId);
                                });

                                if (keys
                                    .contains(productsList[index - 1]['productId'])) {
                                  print('move');
                                  Cart? item = Hive.box<Cart>('cart')
                                      .get(productsList[index - 1]['productId']);
                                  item!.quantity += 1;
                                  item.price += price;
                                  Hive.box<Cart>('cart').put(
                                      productsList[index - 1]['productId'], item);
                                } else {
                                  print('we move');
                                  Box<Cart> cart = Hive.box<Cart>('cart');
                                  cart
                                      .put(
                                    productsList[index - 1]['productId'],
                                    Cart(
                                      productName: productsList[index - 1]
                                      ['name'],
                                      productId: productsList[index - 1]
                                      ['productId'],
                                      price: price,
                                      quantity: 1,
                                      unitPrice: price,
                                    ),
                                  )
                                      .whenComplete(() => print('completed'))
                                      .onError(
                                        (error, stackTrace) => print(error),
                                  );
                                }
                              },
                              child: Container(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Align(
                                      alignment: Alignment.topCenter,
                                      heightFactor: double.infinity,
                                      widthFactor: double.infinity,
                                      child: Column(
                                        children: [
                                          AspectRatio(
                                            aspectRatio: aspectRatio,
                                            child: Container(
                                              //height: 85.0,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: FadeInImage(
                                                    image: NetworkImage(
                                                        '${images.isNotEmpty ? images[0] : ''}'),
                                                    placeholder: AssetImage(
                                                        "assets/default.jpg"),
                                                    imageErrorBuilder:
                                                        (context, error, stackTrace) {
                                                      return Image.asset(
                                                          'assets/default.jpg',
                                                          fit: BoxFit.fitWidth);
                                                    },
                                                    fit: BoxFit.cover,
                                                  ).image,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10.0),
                                                  topRight: Radius.circular(10.0),
                                                ),
                                              ),
                                              // child: CachedNetworkImage(
                                              //   imageUrl:
                                              //       '${images.isNotEmpty ? images[0] : ''}',
                                              //   placeholder: (context, url) {
                                              //     return Image.asset("assets/default.jpg");
                                              //   },
                                              //   errorWidget: (context, url, childs) {
                                              //     return Image.asset(
                                              //       'assets/default.jpg',
                                              //       fit: BoxFit.cover,
                                              //     );
                                              //   },
                                              //   fit: BoxFit.cover,
                                              // ),
                                            ),
                                          ),
                                          Container(
                                            height: 50.0,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: 5.0,
                                                right: 5.0,
                                                top: 2.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${productsList[index - 1]['name']} (${productsList[index - 1]['productId']})',
                                                    style: TextStyle(
                                                      color: kBackgroundColor,
                                                      fontSize: 12.0,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 4.0,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Text(
                                                          discountData.item3
                                                              ? '${currentPrice.toString()}৳'
                                                              : '${currentPrice.toString()}৳/${productsList[index - 1]['sell_by']}',
                                                          style: TextStyle(
                                                            decoration: discountData
                                                                .item3
                                                                ? TextDecoration
                                                                .lineThrough
                                                                : TextDecoration.none,
                                                            color: discountData.item3
                                                                ? kIconColor2
                                                                : Colors.teal[100],
                                                            fontSize: 12.0,
                                                            fontFamily: 'Montserrat',
                                                          ),
                                                        ),
                                                        discountData.item3
                                                            ? Text(
                                                          '${discountData.item1.toString()}৳/${productsList[index - 1]['sell_by']}',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .teal[100],
                                                            fontSize: 12.0,
                                                            fontFamily:
                                                            'Montserrat',
                                                          ),
                                                        )
                                                            : SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: kSubMainColor,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight: Radius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: discountData.item3
                                          ? discountPercentWidget(
                                        discountData.item2.toString(),
                                      )
                                          : SizedBox(),
                                    ),
                                  ],
                                ),
                                //
                                decoration: BoxDecoration(
                                  color: kProductCardColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            );
                      },
                    ),
                  );
                }),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
          FractionallySizedBox(
            heightFactor: 0.1,
            alignment: Alignment.bottomCenter,
            child: Container(
              color: kBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (Hive.box('adminInfo').isNotEmpty) {
                        // List<Cart> cart = Hive.box<Cart>('cart').values.toList();
                        // print(cart[0].productName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShoppingCart(),
                          ),
                        );
                      } else {
                        loginDialogBox(buildContext: context);
                      }
                    },
                    child: ValueListenableBuilder(
                        valueListenable: Hive.box('cartDetails').listenable(),
                        builder: (context, Box box, childs) {
                          int totalItems = box.get('totalItems', defaultValue: 0);
                          var totalPrice = box.get('totalPrice', defaultValue: 0.0);
                          bool isAdded = box.get('isAdded', defaultValue: false);
                          return AnimatedContainer(
                            height: addedToCart ? 47.0 : 45.0,
                            width: addedToCart ? deviceSize.width - 20 : deviceSize.width - 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: kMainColor, width: 2.0),
                              borderRadius: BorderRadius.circular(addedToCart ? 10 : 7.0),
                              color:
                                  isAdded != true ? kBackgroundColor : kMainColor,
                            ),
                            duration: Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                            child: Center(
                              child: Text(
                                totalItems == 0
                                    ? 'No Items'
                                    : '${totalItems.toString()} Items = ${totalPrice.toString()}',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: isAdded != true
                                      ? kMainColor
                                      : kBackgroundColor,
                                  fontFamily: 'Montserrat',
                                  letterSpacing: 1.3,
                                  // fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
