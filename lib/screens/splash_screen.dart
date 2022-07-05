import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/baxes.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/login_page.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

class SplashScreen extends StatefulWidget {
  static String path = '/';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isIndicator = false;
  @override
  GeneralCrud generalCrud = GeneralCrud();
  void initState() {
    // TODO: implement initState
    super.initState();
    generalCrud.getCategories().then(
      (value) {
        final data = value.docs;
        List categories = [];
        data.forEach((element) {
          categories.add(element.data());
        });
        print(categories);
        Hive.box(productsBox).put(catKey, categories).whenComplete(() {
          setState(
            () {
              isIndicator = true;
            },
          );
        });
      },
    ).catchError((error) {
      print(error);
    });
    generalCrud.getProducts().then(
      (value) {
        final data = value.docs;
        List products = [];
        data.forEach((element) {
          products.add(element.data());
        });
        print('Splash screen: $products');
        Hive.box(productsBox).put(productsKey, products).whenComplete(
          () {
            if (Hive.box('adminInfo').isEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginPage();
                  },
                ),
              );
            } else {
              Navigator.popAndPushNamed(context, HomeScreen.path);
            }
          },
        );
      },
    ).catchError((error) {
      print(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: Center(
        child: Image.asset(
          'assets/images/DONE.png',
          width: 200.0,
          height: 200.0,
        ),
      ),
    );
  }
}
