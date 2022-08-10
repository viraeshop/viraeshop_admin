import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/new_product_screen.dart';

import '../components/home_screen_components/decision_components.dart';
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
  StreamSubscription? productsStream;
  static List products = Hive.box(productsBox).get(productsKey);
  static List productsList = [];
  List tempStore = [];
  bool addedToCart = false;
  String dropdownValue = 'general';
  double aspectRatio = 0.0, childAspectRatio = 0.0;
  int crossAxisCount = 3;
  final globalKey = GlobalKey();
  List<GlobalKey> globalKeys = List.generate(
      productsList.isEmpty ? products.length : productsList.length,
      (index) => GlobalKey());
  OverlayEntry? entry;
  @override
  void initState() {
    super.initState();
    Hive.box(productsBox).watch(key: productsKey).listen((event){
      print('event: $event');
      setState((){
        products = event.value;
      });
    });
  }

  void showOverlay(Offset offset, int index, String url) {
    entry = OverlayEntry(builder: (context) {
      return Consumer<AdsProvider>(builder: (context, animation, childs) {
        print('show overlay $index');
        final size = MediaQuery.of(context).size.height;
        return AnimatedPositioned(
            height:
                animation.addedToCart[index] && animation.isAnimationStarted ? 0 : 100.0,
            width:
                animation.addedToCart[index] && animation.isAnimationStarted ? 0 : 150.0,
            left: offset.dx,
            bottom: animation.addedToCart[index]
                ? 0
                : (size - (offset.dy.round() + (offset.dy.round() / 2)))
                    .round()
                    .toDouble(),
            duration: const Duration(milliseconds: 200),
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
            ));
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
    Offset? offset = const Offset(0, 0);
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

  void cartAnimation() {
    setState(() {
      addedToCart = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        addedToCart = false;
      });
    });
  }

  void cartMotionAnimation(int index) {
    Provider.of<AdsProvider>(context, listen: false)
        .animationTrigger(true, index);
    Future.delayed(
      const Duration(milliseconds: 200),
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
      aspectRatio = 3 / 1.90;
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
                  height: 30.0,
                  // width: double.infinity,
                  margin: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButton(
                        value: dropdownValue,
                        items: const [
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
                              return const NonInventoryScreen();
                            }),
                          );
                        },
                        child: const ImageIcon(
                          AssetImage('assets/icons/flash.png'),
                          color: kSubMainColor,
                          size: 25.0,
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(
                //   height: 10.0,
                // ),
                Consumer<AdsProvider>(builder: (consumerContext, ads, childs) {
                  if (widget.isAll) {
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      if (!ads.isSearch && !ads.isAnimationStarted) {
                        ads.updateProductList(products);
                        List<bool> booleans =
                            List.generate(products.length, (index) => false);
                        ads.updateAddedToCart(booleans);
                      }
                    });
                  } else {
                    List classifiedProducts = products.where((element) {
                      return element['category'] == widget.category;
                    }).toList();
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      if (!ads.isSearch && !ads.isAnimationStarted) {
                        ads.updateProductList(classifiedProducts);
                        List<bool> booleans = List.generate(
                            classifiedProducts.length, (index) => false);
                        ads.updateAddedToCart(booleans);
                      }
                    });
                  }
                  productsList = ads.products;
                  return Container(
                    padding: const EdgeInsets.all(10.0),
                    height: deviceSize.height < 741
                        ? deviceSize.height - 400
                        : deviceSize.height - 367,
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
                                child: const Center(
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
                        num currentPrice = getCurrentPrice(
                            productsList[index - 1], dropdownValue);
                        Tuple3<num, num, bool> discountData =
                            computeDiscountData(productsList[index - 1],
                                dropdownValue, currentPrice);
                        return InkWell(
                          key: globalKeys[index - 1],
                          onLongPress: () {
                            if (kDebugMode) {
                              print('longggg hawwa\'u i love you');
                            }
                            showDialog<void>(
                              context: context,
                              // barrierColor: Colors.transparent,
                              builder: (context) => PopWidget(
                                image: productsList[index - 1]['image'],
                                productName: productsList[index - 1]['name'],
                                price: currentPrice.toString(),
                                description: productsList[index - 1]
                                    ['description'],
                                category: productsList[index - 1]['category'],
                                quantity: productsList[index - 1]['quantity']
                                    .toString(),
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
                            if (!ads.isAnimationStarted) {
                              cartAnimation();
                              ads.animationTracker(true);
                              Offset offset = calculateWidgetPosition(
                                  globalKeys[index - 1]);
                              showOverlay(offset, index - 1,
                                  '${images.isNotEmpty ? images[0] : ''}');
                              Future.delayed(const Duration(milliseconds: 20),
                                  () {
                                cartMotionAnimation(index - 1);
                              });
                            }
                            Box cartDetailsBox = Hive.box('cartDetails');
                            num price = discountData.item3
                                ? discountData.item1
                                : currentPrice;
                            int totalItems = cartDetailsBox.get('totalItems',
                                defaultValue: 0);
                            num totalPrice = cartDetailsBox.get('totalPrice',
                                defaultValue: 0.0);
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

                            if (keys.contains(
                                productsList[index - 1]['productId'])) {
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
                                      buyPrice: num.parse(productsList[index - 1]['cost_price'] ?? '0'),
                                    ),
                                  )
                                  .whenComplete(() => print('completed'))
                                  .onError(
                                    (error, stackTrace) => print(error),
                                  );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: kProductCardColor,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
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
                                                placeholder: const AssetImage(
                                                    "assets/default.jpg"),
                                                imageErrorBuilder: (context,
                                                    error, stackTrace) {
                                                  return Image.asset(
                                                      'assets/default.jpg',
                                                      fit: BoxFit.fitWidth);
                                                },
                                                fit: BoxFit.cover,
                                              ).image,
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft:
                                                  Radius.circular(10.0),
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
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: kSubMainColor,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft:
                                                Radius.circular(10),
                                            bottomRight:
                                                Radius.circular(10),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
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
                                                style: const TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12.0,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
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
                                                        decoration:
                                                            discountData.item3
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : TextDecoration
                                                                    .none,
                                                        color: discountData
                                                                .item3
                                                            ? kIconColor2
                                                            : Colors.teal[100],
                                                        fontSize: 12.0,
                                                        fontFamily:
                                                            'Montserrat',
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
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                                      : const SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70.0,
              color: kBackgroundColor,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (Hive.box('customer').isNotEmpty) {
                        // List<Cart> cart = Hive.box<Cart>('cart').values.toList();
                        // print(cart[0].productName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShoppingCart(),
                          ),
                        );
                      } else {
                        toast(context: context, title: 'You Forgot to add Customer', color: kRedColor,);
                      }
                    },
                    child: ValueListenableBuilder(
                        valueListenable: Hive.box('cartDetails').listenable(),
                        builder: (context, Box box, childs) {
                          int totalItems =
                              box.get('totalItems', defaultValue: 0);
                          var totalPrice =
                              box.get('totalPrice', defaultValue: 0.0);
                          bool isAdded =
                              box.get('isAdded', defaultValue: false);
                          return AnimatedContainer(
                            height: addedToCart ? 47.0 : 45.0,
                            width: addedToCart
                                ? deviceSize.width - 20
                                : deviceSize.width - 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: kMainColor, width: 2.0),
                              borderRadius:
                                  BorderRadius.circular(addedToCart ? 10 : 7.0),
                              color: isAdded != true
                                  ? kBackgroundColor
                                  : kMainColor,
                            ),
                            duration: const Duration(milliseconds: 200),
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
                                  fontWeight: FontWeight.bold,
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
