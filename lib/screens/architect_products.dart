import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/product_cards.dart';
import 'package:viraeshop_admin/screens/new_product_screen.dart';
import 'package:viraeshop_admin/screens/product_info.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

class ArchitectProducts extends StatefulWidget {
  static String architectProducts = '/architectproducts';
  const ArchitectProducts({Key? key}) : super(key: key);

  @override
  _ArchitectProductsState createState() => _ArchitectProductsState();
}

class _ArchitectProductsState extends State<ArchitectProducts> {

  // QuerySnapshot? AgentProductsList;

  GeneralCrud generalCrud = GeneralCrud();
  AdminCrud adminCrud = AdminCrud();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    bool isProducts = Hive.box('adminInfo').get('isProducts');
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(
          'Architect Products',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: GestureDetector(
                onTap: isProducts == false
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewProduct()));
                      },
                child: Icon(Icons.add),),
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
              products.forEach((element) {
                productsList.add({
                  'docId': element.id,
                  'name': element.get('name'),
                  'generalPrice': element['generalPrice'],
                    'agentsPrice': element['agentsPrice'],
                    'architectPrice': element['architectPrice'],
                  'description': element.get('description'),                  
                  'cost': element.get('cost_price'),
                  'image': element.get('image'),
                  'category': element.get('category'),
                  'sell_by': element.get('sell_by'),
                  'quantity': element.get('quantity'),
                  'minimum': element.get('minimum'),
                  'generalDiscount': element.get('generalDiscount'),
                    'agentsDiscount': element.get('agentsDiscount'),
                    'architectDiscount': element.get('architectDiscount'),
                    'isGeneralDiscount': element.get('isGeneralDiscount'),
                    'isAgentDiscount': element.get('isAgentDiscount'),
                    'isArchitectDiscount': element.get('isArchitectDiscount'),
                });
                productName.add(element.get('name'));
              });
              print(productsList);
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                margin: EdgeInsets.all(40.0),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(10.0),
                //   boxShadow: [
                //     BoxShadow(
                //       offset: Offset(0, 0),
                //       color: Colors.black38,
                //       blurRadius: 1.0,
                //     ),
                //     BoxShadow(
                //       offset: Offset(0, 0),
                //       color: Colors.black38,
                //       blurRadius: 1.0,
                //     ),
                //   ],
                color: kBackgroundColor,
                child: productName != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Products',
                            style: kTextStyle1,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 600) {
                                  return GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 1 / 1.5,
                                      mainAxisSpacing: 10.0,
                                      crossAxisSpacing: 10.0,
                                    ),
                                    itemCount: products.length,
                                    itemBuilder: (context, i) {
                                      num currentPrice = productsList[i]['architectPrice'];
                                      Tuple3<num, num, bool> discountData =
                                          Tuple3<num, num, bool>(0, 0, false);
                                      bool isDiscount =
                                          productsList[i]['isArchitectDiscount'];
                                      if (isDiscount) {
                                        num discountPercent = percent(
                                            productsList[i]['architectDiscount'],
                                            currentPrice);
                                        num discountPrice = currentPrice -
                                            productsList[i]['architectDiscount'];
                                        discountData = Tuple3<num, num, bool>(
                                            discountPrice,
                                            discountPercent,
                                            isDiscount);
                                      }                                                                            
                                      return ProductCards(
                                        discountPrice: discountData.item1.toString(),
                                        discountPercent: discountData.item2.toString(),
                                        isDiscount: discountData.item3,
                                        productName: productsList[i]['name'],
                                        productDescription: productsList[i]
                                            ['description'],
                                        productPrice:
                                            currentPrice.toString(),
                                        productCategory: productsList[i]
                                            ['category'],
                                        image: productsList[i]['image'],
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductInformation(
                                                productInfo: productsList[i],
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
                                    itemBuilder: (BuildContext context, int i) {
                                      num currentPrice = productsList[i]['architectPrice'];
                                      Tuple3<num, num, bool> discountData =
                                          Tuple3<num, num, bool>(0, 0, false);
                                      bool isDiscount =
                                          productsList[i]['isArchitectDiscount'];
                                      if (isDiscount) {
                                        num discountPercent = percent(
                                            productsList[i]['architectDiscount'],
                                            currentPrice);
                                        num discountPrice = currentPrice -
                                            productsList[i]['architectDiscount'];
                                        discountData = Tuple3<num, num, bool>(
                                            discountPrice,
                                            discountPercent,
                                            isDiscount);
                                      }                                                                            
                                      return ProductCards(
                                        discountPrice: discountData.item1.toString(),
                                        discountPercent: discountData.item2.toString(),
                                        isDiscount: discountData.item3,
                                        productName: productsList[i]['name'],
                                        productDescription: productsList[i]
                                            ['description'],
                                        productPrice:
                                            currentPrice.toString(),
                                        productCategory: productsList[i]
                                            ['category'],
                                        image: productsList[i]['image'][0],
                                        onTap: () {                                          
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => NewProduct(
                                                isUpdateProduct: true,
                                                info: productsList[i],
                                                routeName:
                                                    ArchitectProducts.architectProducts,
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
                    : Text('Loading'),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  //
  myImage(img) {
    return img.split('&token')[0];
  }
}
