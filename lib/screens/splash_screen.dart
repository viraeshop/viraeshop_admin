import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/category/category_bloc.dart';
import 'package:viraeshop_bloc/category/category_event.dart';
import 'package:viraeshop_bloc/category/category_state.dart';
import 'package:viraeshop_bloc/products/barrel.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/screens/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/products/product_category.dart';
import 'package:viraeshop_api/models/products/products.dart' as product;

class SplashScreen extends StatefulWidget {
  static String path = '/';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isIndicator = false;
  bool onError = false;
  String errorMessage = '';
  @override
  void initState() {
    // TODO: implement initState
    final categoryBloc = BlocProvider.of<CategoryBloc>(context);
    if (kDebugMode) {
      print('calling Get Categories()');
    }
    categoryBloc.add(GetCategoriesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kMainColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<CategoryBloc, CategoryState>(
            listener: (BuildContext blocContext, state) {
              final productBloc = BlocProvider.of<ProductsBloc>(context);
              if (state is FetchedCategoryState) {
                debugPrint('Fetched and getting ready');
                List<ProductCategory> data = state.categories.result;
                List categories = [];
                for (var element in data) {
                  categories.add(element.toJson());
                }
                if (kDebugMode) {
                  print(categories);
                }
                Hive.box(productsBox).put(catKey, categories);
                setState(() {
                  isIndicator = true;
                });
                print('Fetching products');
                productBloc.add(GetProductsEvent(
                  queryParameters:  {
                    'queryType': 'admin',
                  }
                ));
              } else if (state is OnErrorCategoryState) {
                debugPrint('Error on Category: ${state.message}');
                setState(() {
                  onError = true;
                  isIndicator = false;
                  errorMessage = state.message;
                });
              }
            },
          ),
          BlocListener<ProductsBloc, ProductState>(
            listener: (context, state) {
              if (state is FetchedProductsState) {
                debugPrint('Fetched the products');
                List<product.Products> data = state.productList;
                debugPrint(data.toString());
                List products = [];
                for (var element in data) {
                  products.add(element.toJson());
                }
                Hive.box(productsBox).put(productsKey, products);
                setState(() {
                  isIndicator = false;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginPage();
                    },
                  ),
                );
              } else if (state is OnErrorProductsState) {
                setState(() {
                  onError = true;
                  isIndicator = false;
                  errorMessage = state.error;
                });
              }
            },
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/DONE.png',
                width: 200.0,
                height: 200.0,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            if (isIndicator)
              const SizedBox(
                  height: 30.0,
                  width: 30.0,
                  child: CircularProgressIndicator(
                    color: kBackgroundColor,
                  )),
            if (onError)
              Text(
                errorMessage,
                style: kBigErrorTextStyle,
              ),
          ],
        ),
      ),
    );
  }
}
