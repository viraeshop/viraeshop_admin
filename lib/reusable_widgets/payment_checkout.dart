import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/customers/customers_screen.dart';
import 'package:viraeshop_admin/screens/payment_screen.dart';

class PaymentCheckout extends StatefulWidget {
  const PaymentCheckout({Key? key}) : super(key: key);

  @override
  _PaymentCheckoutState createState() => _PaymentCheckoutState();
}

class _PaymentCheckoutState extends State<PaymentCheckout> {
  bool isVisible = false;
  num advance = 0;
  bool isAdvance = false, isDue = false, isPaid = true;
  num totalPrice = Hive.box('cartDetails').get('totalPrice');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(
            color: kStrokeColor,
          ),
        ),
        title: const Text(
          'Payment',
          style: kAppBarTitleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(FontAwesomeIcons.chevronLeft),
          color: kSubMainColor,
          iconSize: 20.0,
        ),
        actions: [
          ValueListenableBuilder(
              valueListenable: Hive.box('customer').listenable(),
              builder: (context, Box box, childs) {
                String username = box.get('name');
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
        ],
      ),
      body: Container(
        // padding: EdgeInsets.all(10.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FractionallySizedBox(
              heightFactor: 0.1,
              alignment: Alignment.center,
              child: Container(
                child: Center(
                  child: Text(
                    totalPrice.toString(),
                    style: const TextStyle(
                      color: kBlackColor,
                      fontFamily: 'Montserrat',
                      fontSize: 30,
                      letterSpacing: 1.3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: 0.35,
              child:
                  InkWell(
                    onTap: () {
                      num due = 0, paid = 0;
                      if (isAdvance) {
                        due = totalPrice - advance;
                      } else if (isDue) {
                        advance = 0;
                        due = totalPrice;
                      } else {
                        setState(() {
                          advance = 0;
                          paid = totalPrice;
                        });
                      }
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
                    },
                    child: Container(
                      height: 50.0,
                      width: double.infinity,
                      margin: const EdgeInsets.all(10.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: kMainColor,
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: const Center(
                        child: Text(
                          'Next',
                          style: kDrawerTextStyle2,
                        ),
                      ),
                    ),
                  ),),
            ],
              ),
            ),
    );
  }
}

Widget rowContainer(
    {required String title,
    required IconData icon,
    required dynamic onTap,
    Color color = kBackgroundColor,
    TextStyle style = kProductNameStylePro}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10.0),
      color: color,
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.dollarSign,
            color: color == kNewTextColor ? kBackgroundColor : kSubMainColor,
            size: 20.0,
          ),
          Text(
            title,
            style: style,
          ),
        ],
      ),
    ),
  );
}
