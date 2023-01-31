import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/invoice.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/cart_model.dart';
import 'package:viraeshop_admin/reusable_widgets/hive/shops_model.dart';
import 'package:viraeshop_admin/screens/due/due_receipt.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/reciept_screen.dart';

class DoneScreen extends StatefulWidget {
  final Map info;
  const DoneScreen({required this.info, Key? key}) : super(key: key);

  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    num prices = Hive.box('cartDetails').get('totalPrice');
    String totalPrice = prices.toString();
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(color: kMainColor),
      child: SafeArea(
        child: Scaffold(
          body: Container(
              color: kBackgroundColor,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FractionallySizedBox(
                    heightFactor: 0.76,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.done, size: 100.0, color: kMainColor),
                        const SizedBox(
                          height: 50.0,
                        ),
                        const Text(
                          'Done',
                          style: TextStyle(
                            color: kSubMainColor,
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'BDT $totalPrice',
                          style: const TextStyle(
                            color: kSubMainColor,
                            fontFamily: 'Montserrat',
                            fontSize: 30,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Hive.box<Cart>('cart').clear();
                        Hive.box('cartDetails').clear();
                        Hive.box('customer').clear();
                        Hive.box('shops').clear();
                        Hive.box<Shop>('shopList').clear();
                        Navigator.pop(context);
                      },
                      icon: const Icon(FontAwesomeIcons.chevronLeft),
                      iconSize: 30.0,
                      color: kMainColor,
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: 0.24,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return DueReceipt(
                                      title: 'Receipt',
                                      isOnlyShow: true,
                                      data: widget.info,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kSubMainColor,
                              ),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: const Center(
                              child: Text(
                                'Download Receipt',
                                style: kProductNameStyle,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Hive.box<Cart>('cart').clear();
                            Hive.box('cartDetails').clear();
                            Hive.box('customer').clear();
                            Hive.box('shops').clear();
                            Hive.box<Shop>('shopList').clear();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                                (route) => false);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: const Center(
                              child: Text(
                                'Start a new sale',
                                style: kDrawerTextStyle1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
