import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:random_string/random_string.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/edit_unit_price.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/shops_model.dart';
import 'package:viraeshop_admin/reusable_widgets/quantity.dart';
import 'package:viraeshop_admin/screens/cart_payment_options/advance.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/discount.dart';
import 'package:viraeshop_admin/screens/payment_screen.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import '../screens/customers/customers_screen.dart';
import 'hive/cart_model.dart';

class ShoppingCart extends StatefulWidget {
  static String path = '/cart';
  const ShoppingCart({Key? key}) : super(key: key);

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  GeneralCrud generalCrud = GeneralCrud();
  AdminCrud adminCrud = AdminCrud();
  var currDate = DateTime.now();
  var cartItems = [];
  int itemCount = 0;
  String orderCode = randomAlphaNumeric(10);

  String total = '';
  int totalQuantity = 0;
  Map userInfo = {};
  bool isProcessing = false;
  bool isDesc = false;
  TextEditingController descController = TextEditingController(text: ' 0');
  List<Cart> carts = Hive.box<Cart>('cart').values.toList();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool isVisible = false;
  num totalPrice = 0;
  num advance = 0;
  num due = 0;
  num paid = 0;
  String selected = '';
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      inAsyncCall: isProcessing,
      child: Scaffold(
        appBar: AppBar(
          shape: const Border(
            bottom: BorderSide(
              color: Colors.black12,
            ),
          ),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              FontAwesomeIcons.chevronLeft,
              color: kSubMainColor,
            ),
          ),
          title: const Text(
            'Cart',
            style: kAppBarTitleTextStyle,
          ),
          actions: [
            ValueListenableBuilder(
                valueListenable: Hive.box('customer').listenable(),
                builder: (context, Box box, childs) {
                  String username = box.get('role') != 'general'
                      ? box.get('businessName', defaultValue: '') +
                          '(${box.get('name')})'
                      : box.get('name', defaultValue: '');
                  if (box.values.isEmpty) {
                    return IconButton(
                      color: kMainColor,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CustomersScreen()));
                      },
                      icon: const Icon(FontAwesomeIcons.userPlus),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomersScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: kSubMainColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.userPlus,
                              color: kSubMainColor,
                              size: 10.0,
                            ),
                            const SizedBox(width: 7.0),
                            Text(
                              username,
                              style: const TextStyle(
                                color: kSubMainColor,
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                letterSpacing: 1.3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: IconButton(
                  color: kMainColor,
                  onPressed: () {
                    // Clear Cart
                    popDialog(
                        title: 'Empty cart',
                        context: context,
                        widget: SingleChildScrollView(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              const Text(
                                  'Are you sure you want to clear your cart?'),
                              const SizedBox(height: 20),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color:
                                          kMainColor, //Theme.of(context).accentColor,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Clear Cart",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  //  Clear
                                  Hive.box<Cart>('cart').clear();
                                  Hive.box('cartDetails').clear();
                                  Hive.box<Shop>('shopList').clear();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ));
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  )),
            ),
          ],
        ),
        body: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: Hive.box<Cart>('cart').listenable(),
              builder: (context, Box<Cart> box, childs) {
                List<Cart> carts = box.values.toList();
                List keys = box.keys.toList();
                if (carts.isNotEmpty) {
                  return Container(
                    color: kStrokeColor,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FractionallySizedBox(
                          heightFactor: 0.9,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            // height: MediaQuery.of(context).size.height * 0.8,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Column(
                                    children: List.generate(
                                      carts.length,
                                      (int i) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            color: kBackgroundColor,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Color(0xffF7F7F7),
                                              ),
                                            ),
                                          ),
                                          child: CollapsableWidget(
                                            quantity:
                                                carts[i].quantity.toString(),
                                            name: carts[i].productName,
                                            code: carts[i].productCode,
                                            price: carts[i]
                                                .productPrice
                                                .toString(),
                                            keyStore: keys[i],
                                            unitPrice:
                                                carts[i].unitPrice.toString(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, top: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ValueListenableBuilder(
                                            valueListenable:
                                                Hive.box('cartDetails')
                                                    .listenable(),
                                            builder:
                                                (context, Box box, childs) {
                                              num prices = box.get('totalPrice',
                                                  defaultValue: 0);
                                              totalPrice = prices;
                                              num discounts = box.get(
                                                  'discountAmount',
                                                  defaultValue: 0);
                                              num discountPercent = box.get(
                                                  'discountPercent',
                                                  defaultValue: 0);
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  discounts != null
                                                      ? Text(
                                                          'Total: ${prices.toString()}',
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                kSubMainColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontSize: 15,
                                                            letterSpacing: 1.3,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                  const SizedBox(height: 3.0),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return const DiscountScreen();
                                                      }));
                                                    },
                                                    child: Text(
                                                      box.containsKey(
                                                              'discountAmount')
                                                          ? 'Discount(${discountPercent.round().toString()}%): -${discounts.toString()}৳'
                                                          : 'Add Discount',
                                                      style: const TextStyle(
                                                        color: kIconColor1,
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 14,
                                                        letterSpacing: 1.3,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 3.0),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ValueListenableBuilder(
                                            valueListenable:
                                                Hive.box('cartDetails')
                                                    .listenable(),
                                            builder:
                                                (context, Box box, childs) {
                                              num totalPrice = box.get(
                                                      'totalPrice',
                                                      defaultValue: 0) -
                                                  box.get('discountAmount',
                                                      defaultValue: 0);
                                              return Text(
                                                'Sub-Total: ${totalPrice.toString()}',
                                                style: const TextStyle(
                                                  color: kSubMainColor,
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15,
                                                  letterSpacing: 1.3,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                  //SizedBox(height: 3.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: ValueListenableBuilder(
                                            valueListenable:
                                                Hive.box('cartDetails')
                                                    .listenable(),
                                            builder:
                                                (context, Box box, childs) {
                                              num discount = box.get(
                                                  'discountAmount',
                                                  defaultValue: 0);
                                              if (advance != 0) {
                                                due = totalPrice -
                                                    advance -
                                                    discount;
                                              }
                                              return TypableText(
                                                isDesc: isDesc,
                                                controller: descController,
                                                switchOn: () {
                                                  setState(() {
                                                    isDesc = true;
                                                    selected = '';
                                                    due = 0;
                                                    paid = 0;
                                                    // paid = 0;
                                                  });
                                                },
                                                switchOff: () {
                                                  setState(() {
                                                    isDesc = false;
                                                  });
                                                },
                                                onChanged: (e) {
                                                  setState(() {
                                                    due = totalPrice -
                                                        num.parse(e) -
                                                        discount;
                                                    advance = num.parse(e);
                                                    paid = advance;
                                                  });
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ValueListenableBuilder(
                                          valueListenable:
                                              Hive.box('cartDetails')
                                                  .listenable(),
                                          builder: (context, Box box, childs) {
                                            num totalPrice =
                                                box.get('totalPrice');
                                            num discount = box.get(
                                                'discountAmount',
                                                defaultValue: 0);
                                            if (selected == 'due') {
                                              // selected = 'due';
                                              paid = 0;
                                              advance = 0;
                                              due = totalPrice - discount;
                                              descController.text = '0';
                                            }
                                            return TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    selected = 'due';
                                                    paid = 0;
                                                    advance = 0;
                                                    due = totalPrice - discount;
                                                    descController.text = '0';
                                                  });
                                                },
                                                child: Text(
                                                  'Due: ${due.toString()}',
                                                  style: const TextStyle(
                                                    color: kSubMainColor,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 15,
                                                    letterSpacing: 1.3,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ValueListenableBuilder(
                                            valueListenable:
                                                Hive.box('cartDetails')
                                                    .listenable(),
                                            builder:
                                                (context, Box box, childs) {
                                              num totalPrice =
                                                  box.get('totalPrice');
                                              num discount = box.get(
                                                  'discountAmount',
                                                  defaultValue: 0);
                                              if (selected == 'paid') {
                                                // selected = 'due';

                                                paid = totalPrice - discount;
                                                advance = 0;
                                                due = 0;
                                                descController.text = '0';
                                              }
                                              return TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    selected = 'paid';
                                                    paid =
                                                        totalPrice - discount;
                                                    advance = 0;
                                                    due = 0;
                                                    descController.text = '0';
                                                  });
                                                },
                                                child: Text(
                                                  'Paid: ${paid.toString()}',
                                                  style: const TextStyle(
                                                    color: kSubMainColor,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 15,
                                                    letterSpacing: 1.3,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        FractionallySizedBox(
                          heightFactor: 0.1,
                          alignment: Alignment.bottomCenter,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  color: kBackgroundColor,
                                  child: InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      margin: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          color:
                                              kMainColor, //Theme.of(context).accentColor,
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ValueListenableBuilder(
                                            valueListenable:
                                                Hive.box('cartDetails')
                                                    .listenable(),
                                            builder:
                                                (context, Box box, childs) {
                                              var totalPrice =
                                                  box.get('totalPrice') -
                                                      box.get('discountAmount',
                                                          defaultValue: 0);
                                              int totalItems =
                                                  box.get('totalItems');
                                              return Text(
                                                'Order ${totalItems.toString()} Items at ${totalPrice.toString()}৳',
                                                style: const TextStyle(
                                                  color: kBackgroundColor,
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 20.0,
                                                  letterSpacing: 1.3,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      final customer = Hive.box('customer');
                                      if (paid == 0 &&
                                          due == 0 &&
                                          advance == 0) {
                                        toast(
                                          context: context,
                                          title:
                                              'You have not complete the payment status!',
                                          color: kRedColor,
                                        );
                                      } else if (customer.values.isEmpty) {
                                        toast(
                                          context: context,
                                          title:
                                              'You have not selected a customer!',
                                          color: kRedColor,
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                              paid: paid,
                                              due: due,
                                              advance: advance,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      color: const Color(0xfff7f7f7),
                      child: const Text(
                        'Cart is empty',
                        style: kProductNameStyle,
                      ),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}

class CollapsableWidget extends StatefulWidget {
  final String quantity, name, price, unitPrice, code;
  var keyStore;
  CollapsableWidget({
    super.key,
    required this.quantity,
    required this.name,
    required this.price,
    required this.keyStore,
    required this.unitPrice,
    required this.code,
  });
  @override
  _CollapsableWidgetState createState() => _CollapsableWidgetState();
}

class _CollapsableWidgetState extends State<CollapsableWidget> {
  bool isVisible = false;
  bool isAdvanceVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
            child: Row(
              children: [
                Text(
                  widget.quantity,
                  style: const TextStyle(
                    color: kSubMainColor,
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ' X',
                  style: TextStyle(
                    color: Colors.black12,
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          title: Text('${widget.name} (${widget.code})',
              style: kProductNameStylePro),
          subtitle: Text('${widget.unitPrice}৳', style: kProductNameStylePro),
          trailing: Text(
            /// To add product price here
            '${widget.price}৳',
            style: const TextStyle(
              color: kSubMainColor,
              fontFamily: 'Montserrat',
              fontSize: 14,
              letterSpacing: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            setState(() {
              isVisible = !isVisible;
            });
          },
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          height: isVisible ? 100 : 0,
          width: double.infinity,
          //padding: EdgeInsets.all(0.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: kStrokeColor,
              ),
              top: BorderSide(
                color: kStrokeColor,
              ),
            ),
            color: kBackgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return QuantityScreen(
                            keyStore: widget.keyStore,
                          );
                        }));
                      },
                      icon: const Icon(
                        Icons.inventory,
                        size: 20.0,
                        color: kSubMainColor,
                      ),
                    ),
                    Text('${widget.quantity} Items',
                        style: kProductNameStylePro),
                  ],
                ),
              ),
              const VerticalDivider(
                color: kStrokeColor,
                thickness: 2.0,
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return alert(
                              context: context,
                              title: 'Remove Discount?',
                              message:
                                  'Once you edit this product, the discount that\'s been already applied to it will be removed. Would you like to proceed?',
                              onTap: () {
                                Box box = Hive.box('cartDetails');
                                Cart? item =
                                    Hive.box<Cart>('cart').get(widget.keyStore);
                                item!.discount = 0;
                                item.discountPercent = 0;
                                Hive.box<Cart>('cart')
                                    .put(widget.keyStore, item);
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return EditUnitPrice(
                                        keyStore: widget.keyStore,
                                        name: widget.name,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.dollarSign,
                          size: 20.0, color: Colors.red),
                    ),
                    Text('BDT ${widget.unitPrice}',
                        style: kProductNameStylePro),
                    const Text(
                      'Unit',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 12.0,
                        fontFamily: 'Montserrat',
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                color: kStrokeColor,
                thickness: 4.0,
              ),
              ValueListenableBuilder(
                  valueListenable: Hive.box<Cart>('cart').listenable(),
                  builder: (context, Box box, childs) {
                    Cart? item = box.get(widget.keyStore);
                    bool isDiscount = item!.discount != 0;
                    return Container(
                      color: isDiscount ? kRedColor : kBackgroundColor,
                      //width: double.infinity,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DiscountScreen(
                                  keyStore: widget.keyStore,
                                  isItems: true,
                                );
                              }));
                            },
                            icon: Icon(Icons.local_offer,
                                size: 20.0,
                                color:
                                    isDiscount ? kBackgroundColor : Colors.red),
                          ),
                          Text(
                            'Discount',
                            style: isDiscount
                                ? kDrawerTextStyle2
                                : kProductNameStylePro,
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }
}

Widget alert(
    {required String title,
    message,
    dynamic onTap,
    required BuildContext context}) {
  return AlertDialog(
    title: Text(title),
    content: Text(
      message,
      softWrap: true,
      style: kSourceSansStyle,
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          'CANCEL',
          softWrap: true,
          style: kSourceSansStyle,
        ),
      ),
      TextButton(
        onPressed: onTap,
        child: const Text(
          'YES',
          softWrap: true,
          style: kSourceSansStyle,
        ),
      )
    ],
  );
}
