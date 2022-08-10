import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/product_cards.dart';
import 'package:viraeshop_admin/screens/new_product_screen.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

class Products extends StatefulWidget {
  static String productsPath = '/products';
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  // QuerySnapshot? productsList;

  GeneralCrud generalCrud = GeneralCrud();
  AdminCrud adminCrud = AdminCrud();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  String dropdownValue = 'general';
  @override
  Widget build(BuildContext context) {
    final bool isProduct = Hive.box('adminInfo').get('isProducts');
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        backgroundColor: kScaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: constraints.maxWidth > 600 ? false : true,
          iconTheme: const IconThemeData(color: kSelectedTileColor),
          elevation: 3.0,
          backgroundColor: kBackgroundColor,
          title: const Text(
            'Products',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
          // bottom: TabBar(
          //   tabs: tabs,
          // ),
          actions: [
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
            const SizedBox(
              width: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: GestureDetector(
                onTap: isProduct == false
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewProduct()));
                      },
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        body: FutureBuilder<QuerySnapshot>(
            future: generalCrud.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final products = snapshot.data!.docs;
                List<String> productName = [];
                List productsList = [];
                for (var element in products) {
                  productsList.add(element.data());
                  productName.add(element.get('name'));
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.all(40.0),
                  color: kBackgroundColor,
                  child: productName.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'All Products',
                              style: kTextStyle1,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.maxWidth > 800) {
                                    return GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 1 / 1.5,
                                        mainAxisSpacing: 10.0,
                                        crossAxisSpacing: 10.0,
                                      ),
                                      itemCount: products.length,
                                      itemBuilder: (context, i) {
                                        num currentPrice = 0;
                                        Tuple3<num, num, bool> discountData =
                                            const Tuple3<num, num, bool>(0, 0, false);
                                        if (dropdownValue == 'general') {
                                          currentPrice =
                                              productsList[i]['generalPrice'];
                                          bool isDiscount = productsList[i]
                                              ['isGeneralDiscount'];
                                          if (isDiscount) {
                                            num discountPercent = percent(
                                                productsList[i]
                                                    ['generalDiscount'],
                                                productsList[i]
                                                    ['generalPrice']);
                                            num discountPrice = productsList[i]
                                                    ['generalPrice'] -
                                                productsList[i - 1]
                                                    ['generalDiscount'];
                                            discountData =
                                                Tuple3<num, num, bool>(
                                                    discountPrice,
                                                    discountPercent,
                                                    isDiscount);
                                          }
                                        } else if (dropdownValue == 'agents') {
                                          currentPrice =
                                              productsList[i]['agentsPrice'];
                                          bool isDiscount = productsList[i]
                                              ['isAgentDiscount'];
                                          if (isDiscount) {
                                            num discountPercent = percent(
                                                productsList[i]
                                                    ['agentsDiscount'],
                                                currentPrice);
                                            num discountPrice = currentPrice -
                                                productsList[i]
                                                    ['agentsDiscount'];
                                            discountData =
                                                Tuple3<num, num, bool>(
                                                    discountPrice,
                                                    discountPercent,
                                                    isDiscount);
                                          }
                                        } else {
                                          currentPrice =
                                              productsList[i]['architectPrice'];
                                          bool isDiscount = productsList[i]
                                              ['isArchitectDiscount'];
                                          if (isDiscount) {
                                            num discountPercent = percent(
                                                productsList[i]
                                                    ['architectDiscount'],
                                                currentPrice);
                                            num discountPrice = currentPrice -
                                                productsList[i]
                                                    ['architectDiscount'];
                                            discountData =
                                                Tuple3<num, num, bool>(
                                                    discountPrice,
                                                    discountPercent,
                                                    isDiscount);
                                          }
                                        }
                                        return ProductCards(
                                          discountPrice:
                                              discountData.item1.toString(),
                                          discountPercent:
                                              discountData.item2.toString(),
                                          isDiscount: discountData.item3,
                                          productName: productsList[i]['name'],
                                          productDescription: productsList[i]
                                              ['description'],
                                          productPrice: currentPrice.toString(),
                                          productCategory: productsList[i]
                                              ['category'],
                                          image: productsList[i]['image'][0],
                                          onTap:!isProduct ? null :  () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NewProduct(
                                                      isUpdateProduct: true,
                                                      info: productsList[i],
                                                      routeName:
                                                      Products.productsPath,
                                                    ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  } else {
                                    return ListView.builder(
                                      itemCount: products.length,
                                      itemBuilder:
                                          (BuildContext context, int i) {
                                        num currentPrice = 0;
                                        List images = productsList[i]['image'];
                                        Tuple3<num, num, bool> discountData =
                                            const Tuple3<num, num, bool>(0, 0, false);
                                        if (dropdownValue == 'general') {
                                          currentPrice =
                                              productsList[i]['generalPrice'];
                                          bool isDiscount = productsList[i]
                                              ['isGeneralDiscount'];
                                          if (isDiscount) {
                                            num discountPercent = percent(
                                                productsList[i]
                                                    ['generalDiscount'],
                                                productsList[i]
                                                    ['generalPrice']);
                                            num discountPrice = productsList[i]
                                                    ['generalPrice'] -
                                                productsList[i]
                                                    ['generalDiscount'];
                                            discountData =
                                                Tuple3<num, num, bool>(
                                                    discountPrice,
                                                    discountPercent,
                                                    isDiscount);
                                          }
                                        } else if (dropdownValue == 'agents') {
                                          currentPrice =
                                              productsList[i]['agentsPrice'];
                                          bool isDiscount = productsList[i]
                                              ['isAgentDiscount'];
                                          if (isDiscount) {
                                            num discountPercent = percent(
                                                productsList[i]
                                                    ['agentsDiscount'],
                                                currentPrice);
                                            num discountPrice = currentPrice -
                                                productsList[i]
                                                    ['agentsDiscount'];
                                            discountData =
                                                Tuple3<num, num, bool>(
                                                    discountPrice,
                                                    discountPercent,
                                                    isDiscount);
                                          }
                                        } else {
                                          currentPrice =
                                              productsList[i]['architectPrice'];
                                          bool isDiscount = productsList[i]
                                              ['isArchitectDiscount'];
                                          if (isDiscount) {
                                            num discountPercent = percent(
                                                productsList[i]
                                                    ['architectDiscount'],
                                                currentPrice);
                                            num discountPrice = currentPrice -
                                                productsList[i]
                                                    ['architectDiscount'];
                                            discountData =
                                                Tuple3<num, num, bool>(
                                                    discountPrice,
                                                    discountPercent,
                                                    isDiscount);
                                          }
                                        }
                                        return ProductCards(
                                          discountPrice:
                                              discountData.item1.toString(),
                                          discountPercent:
                                              discountData.item2.toString(),
                                          isDiscount: discountData.item3,
                                          productName: productsList[i]['name'],
                                          productDescription: productsList[i]
                                              ['description'],
                                          productPrice: currentPrice.toString(),
                                          productCategory: productsList[i]
                                              ['category'],
                                          image: images.isNotEmpty
                                              ? images[0]
                                              : '',
                                          onTap: !isProduct ? null : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NewProduct(
                                                  isUpdateProduct: true,
                                                  info: productsList[i],
                                                  routeName:
                                                      Products.productsPath,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : const Text('Loading'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
