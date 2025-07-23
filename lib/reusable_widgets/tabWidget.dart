import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';
import 'package:viraeshop_admin/reusable_widgets/popWidget.dart';
import 'package:viraeshop_admin/reusable_widgets/shopping_cart.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/products/new_product_screen.dart';
import 'package:viraeshop_admin/reusable_widgets/category/special_category_models.dart';
import 'package:dart_date/dart_date.dart';

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
  const TabWidget({super.key, this.category = '', this.isAll = true});
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
  double aspectRatio = 0.0, childAspectRatio = 0.0;
  int crossAxisCount = 3;
  final globalKey = GlobalKey();
  List<GlobalKey> globalKeys = List.generate(
      productsList.isEmpty ? products.length : productsList.length,
      (index) => GlobalKey());
  OverlayEntry? entry;
  @override
  void initState() {
    Hive.box(productsBox).watch(key: productsKey).listen((event) {
      if (kDebugMode) {
        print('event: $event');
      }
      products = event.value;
      productsList = event.value;
    }).onError((_) {
      if (kDebugMode) {
        print(_);
      }
    });
    super.initState();
  }

  void showOverlay(Offset offset, int index, String url) {
    entry = OverlayEntry(builder: (context) {
      return Consumer<AdsProvider>(builder: (context, animation, childs) {
        final size = MediaQuery.of(context).size.height;
        return AnimatedPositioned(
            height: animation.addedToCart[index] && animation.isAnimationStarted
                ? 0
                : 100.0,
            width: animation.addedToCart[index] && animation.isAnimationStarted
                ? 0
                : 150.0,
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
                    url,
                  ),
                  fit: BoxFit.contain,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ));
      });
    });
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
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
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
//    if (deviceSize.width <= 480) {
    // mobile screen sizes
    aspectRatio = 1.15; // Image aspect ratio
    childAspectRatio = 0.76; // Grid item aspect ratio
    crossAxisCount = 3;
    // } else if (deviceSize.width > 480 && deviceSize.width <= 768) {
    //   // Ipads/ Tablets screens
    //   aspectRatio = 16.0 / 10.0;
    //   childAspectRatio = 16 / 15.5;
    //   crossAxisCount = 4;
    // } else if (deviceSize.width > 768 && deviceSize.width <= 1024) {
    //   // Small screens and Laptops
    //   aspectRatio = 16.0 / 8.8;
    //   childAspectRatio = 16 / 14.5;
    //   crossAxisCount = 5;
    // } else if (deviceSize.width > 1024) {
    //   // Desktops and Large Screens
    //   aspectRatio = 16.0 / 8.8;
    //   childAspectRatio = 16 / 12.5;
    //   crossAxisCount = 5;
    // }
    return Container(
      color: kBackgroundColor,
      child: Stack(
        children: [
          FractionallySizedBox(
            heightFactor: 0.95,
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
                      isSecondRow: false,
                    );
                  },
                ),
                Consumer<AdsProvider>(builder: (context, ads, childs) {
                  //print(ads.hasSubCatg);
                  return Categories(
                    catLength: ads.hasSubCatg
                        ? ads.subCategories.length
                        : specialCategories.length,
                    categories:
                        ads.hasSubCatg ? ads.subCategories : specialCategories,
                    isSecondRow: true,
                  );
                }),
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
                    /**
                     * This classified is the list of all products but
                     * it gets updated base on the current category
                     * if the category have a sub category,
                     * it will be updated based on that.
                     */
                    List classifiedProducts = [];
                    if (ads.hasSubCatg && ads.subCategory.isNotEmpty) {
                      classifiedProducts = products.where((element) {
                        return element['subCategory'] == ads.subCategory;
                      }).toList();
                    } else if (widget.category == 'Top Discount') {
                      classifiedProducts = products.where((element) {
                        return element['topDiscount'] ?? false;
                      }).toList();
                    } else if (widget.category == 'Free Shipping') {
                      classifiedProducts = products.where((element) {
                        return element['freeShipping'] ?? false;
                      }).toList();
                    } else if (widget.category == 'Coming Soon') {
                      classifiedProducts = products.where((element) {
                        return element['comingSoon'] ?? false;
                      }).toList();
                    } else if (widget.category == 'New Arrival') {
                      classifiedProducts = products.where((element) {
                        final currentMonth = DateTime.now();
                        final previousMonth = currentMonth.previousMonth;
                        final registeredDate =
                            DateTime.parse(element['createdAt']);
                        if (currentMonth.isSameOrBefore(registeredDate) &&
                            previousMonth.isSameOrAfter(registeredDate)) {
                          return true;
                        } else {
                          return false;
                        }
                      }).toList();
                    } else {
                      classifiedProducts = products.where((element) {
                        return element['category'] == widget.category;
                      }).toList();
                    }
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
                    height: deviceSize.height * 0.6,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                      ),
                      itemCount: productsList.length + 1,
                      itemBuilder: (gridContext, index) {
                        if (index == 0) {
                          final bool isProduct = Hive.box('adminInfo')
                              .get('isProducts', defaultValue: false);
                          return InkWell(
                            onTap: isProduct == false
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const NewProduct(
                                          info: {},
                                        ),
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
                        String thumbnailImage =
                            productsList[index - 1]['thumbnail'];
                        num originalPrice = getCurrentPrice(
                            productsList[index - 1], ads.dropdownValue);
                        Tuple3<num, num, bool> discountData =
                            computeDiscountData(productsList[index - 1],
                                ads.dropdownValue, originalPrice);
                        //print(productsList[0]);
                        return InkWell(
                          key: globalKeys[index - 1],
                          onLongPress: () {
                            if (kDebugMode) {
                              print('longggg hawwa\'u i love you');
                            }
                            List productPics =
                                productsList[index - 1]['images'] ?? [];
                            productPics.insert(0, {
                              'imageLink': thumbnailImage,
                              'imageKey': productsList[index - 1]
                                  ['thumbnailKey'],
                            });
                            showDialog<void>(
                              context: context,
                              // barrierColor: Colors.transparent,
                              builder: (context) => PopWidget(
                                image: productPics
                                    .map((e) => e['imageLink'])
                                    .toList(),
                                productName: productsList[index - 1]['name'],
                                productCode: productsList[index - 1]
                                    ['productCode'],
                                price: originalPrice.toString(),
                                description: productsList[index - 1]
                                    ['description'],
                                category: productsList[index - 1]['category'],
                                quantity: productsList[index - 1]['quantity']
                                    .toString(),
                                info: productsList[index - 1],
                                routeName: HomeScreen.path,
                                isDiscount: discountData.item3,
                                discountPrice: discountData.item1,
                                sellBy: productsList[index - 1]['sellBy'],
                              ),
                            );
                          },
                          onTap: () {
                            if (!ads.isAnimationStarted) {
                              cartAnimation();
                              ads.animationTracker(true);
                              Offset offset = calculateWidgetPosition(
                                  globalKeys[index - 1]);
                              showOverlay(
                                offset,
                                index - 1,
                                thumbnailImage,
                              );
                              Future.delayed(const Duration(milliseconds: 20),
                                  () {
                                cartMotionAnimation(index - 1);
                              });
                            }
                            Box cartDetailsBox = Hive.box('cartDetails');
                            num price = discountData.item3
                                ? discountData.item1
                                : originalPrice;
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
                            List keys = Hive.box<Cart>('cart').keys.toList();
                            if (keys.contains(
                                productsList[index - 1]['productId'])) {
                              Cart? item = Hive.box<Cart>('cart')
                                  .get(productsList[index - 1]['productId']);
                              item!.quantity += 1;
                              item.productPrice += price;
                              Hive.box<Cart>('cart').put(
                                  productsList[index - 1]['productId'], item);
                            } else {
                              Box<Cart> cart = Hive.box<Cart>('cart');
                              cart.put(
                                productsList[index - 1]['productId'],
                                Cart(
                                  productName: productsList[index - 1]['name'],
                                  productId: productsList[index - 1]
                                      ['productId'],
                                  productCode: productsList[index - 1]
                                      ['productCode'],
                                  productPrice: price,
                                  quantity: 1,
                                  unitPrice: price,
                                  isInventory: productsList[index - 1]['isNonInventory'] ? false : true,
                                  buyPrice: productsList[index - 1]['costPrice']
                                              .runtimeType ==
                                          String
                                      ? num.parse(productsList[index - 1]
                                              ['costPrice'] ??
                                          '0')
                                      : productsList[index - 1]['costPrice'],
                                  productImage: productsList[index - 1]
                                      ['thumbnail'],
                                  originalPrice: originalPrice,
                                  discount: discountData.item3
                                      ? originalPrice - discountData.item1
                                      : 0,
                                  discountPercent: discountData.item2,
                                  supplierId: productsList[index - 1]
                                      ['supplier']['supplierId'],
                                ),
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
                                                image:
                                                    CachedNetworkImageProvider(
                                                  thumbnailImage,
                                                ),
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
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 60.0,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: kSubMainColor,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
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
                                                '${productsList[index - 1]['name']} (${productsList[index - 1]['productCode']})',
                                                style: const TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12.0,
                                                  fontFamily: 'Montserrat',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${productsList[index - 1]['productCode']}',
                                                style: const TextStyle(
                                                  color: kBackgroundColor,
                                                  fontSize: 12.0,
                                                  fontFamily: 'Montserrat',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                          ? '${originalPrice.toString()}৳'
                                                          : '${originalPrice.toString()}৳/${productsList[index - 1]['sellBy']}',
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
                                                        fontSize: 10.0,
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                    ),
                                                    discountData.item3
                                                        ? Text(
                                                            '${discountData.item1.toString()}৳/${productsList[index - 1]['sellBy']}',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .teal[100],
                                                              fontSize: 10.0,
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
          SafeArea(
            child: Align(
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
                        // List<Cart> cart = Hive.box<Cart>('cart').values.toList();
                        // print(cart[0].productName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ShoppingCart(),
                          ),
                        );
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
            ),
          )
        ],
      ),
    );
  }
}
