import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/screens/add_user.dart';
import 'package:viraeshop_admin/reusable_widgets/drawer.dart';
import 'package:viraeshop_admin/reusable_widgets/resusable_tile.dart';
import 'package:viraeshop_admin/screens/products/new_product_screen.dart';
import 'package:viraeshop_admin/screens/product_info.dart';
import 'package:viraeshop_admin/screens/products_screen.dart';
import 'package:viraeshop_admin/screens/user_list.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';
import 'layout_screen/modal_view.dart';
import 'layout_screen/standard_view.dart';

class HomeScreen extends StatefulWidget {
  static String path = '/homescreen';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AdminCrud adminCrud = AdminCrud();
  @override
  bool _selected = true;
  bool _unSelected = false;
  bool? isSelected;
  bool onTile() {
    if (isSelected == null) {
      return _selected;
    } else {
      return _unSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > 768) {
          return StandardView();
        } else {
          return ModalWidget();
        }
      }),
    );
  }

// My Dialog
//   myDialog({title = '', price = ''}) {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           Widget alertd = AlertDialog(
//             actions: [
//               Center(child: Text("Price: \$$price")),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   keyboardType: TextInputType.number,
//                   controller: null,
//                   decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15))),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: InkWell(
//                   child: Container(
//                     padding: EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: kMainColor, //Theme.of(context).accentColor,
//                         borderRadius: BorderRadius.circular(15)),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Add To Cart",
//                           style: TextStyle(fontSize: 20, color: Colors.white),
//                         )
//                       ],
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ],
//             title: Text(
//               title,
//               textAlign: TextAlign.center,
//             ),
//           );
//           return alertd;
//         });
//   }

//   // Home Page

// }

// // Home Page
// Widget pageOne() {
//   return SingleChildScrollView(
//     padding: EdgeInsets.all(10.0),
//     child: Column(
//       children: [
//         // SizedBox(
//         //   height: 10.0,
//         // ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [],
//         ),
//         SizedBox(
//           height: 10.0,
//         ),
//         Container(
//           //LimitedBox
//           // maxHeight: 500.0,
//           child: FutureBuilder<QuerySnapshot>(
//               future: new GeneralCrud().getProducts(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final products = snapshot.data!.docs;
//                   List<String> productName = [];
//                   List<Map> productsList = [];
//                   List datum = [];
//                   products.forEach((element) {
//                     datum.add(element.data());
//                   });
//                   products.forEach((element) {
//                     productsList.add({
//                       'id': element.id,
//                       'name': element.get('name'),
//                       'price': element.get('selling_price'),
//                       'quantity': element.get('quantity'),
//                       'image': element.get('image')
//                     });
//                     productName.add(element.get('name'));
//                     // print(jsonEncode(productsList));
//                   });
//                   return ProductWidget(
//                       productName: productName,
//                       products: products,
//                       productsList: datum);
//                 }
//                 return Center(child: CircularProgressIndicator());
//               }),

//           // Page two
//         ),
//       ],
//     ),
//   );
// }

// class ProductWidget extends StatelessWidget {
//   const ProductWidget({
//     Key? key,
//     required this.productName,
//     required this.products,
//     required this.productsList,
//   }) : super(key: key);

//   final List<String> productName;
//   final List<QueryDocumentSnapshot<Object?>> products;
//   final List productsList;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: productName != null
//           ? GridView.builder(
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 childAspectRatio: MediaQuery.of(context).size.width /
//                     MediaQuery.of(context).size.width /
//                     0.6 /
//                     1.5,
//                 mainAxisSpacing: 10.0,
//                 crossAxisSpacing: 10.0,
//               ),
//               itemCount: products.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   final bool isProduct = Hive.box('adminInfo').get('isProduct');
//                   return InkWell(
//                     onTap: isProduct == false
//                         ? null
//                         : () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => NewProduct(),
//                               ),
//                             );
//                           },
//                     child: LayoutBuilder(
//                       builder: (context, constraints) => Container(
//                         // height: constraints.maxWidth > 600 ? 100.0 : 20.0,
//                         // width: constraints.maxWidth > 600 ? 100.0 : 20.0,
//                         decoration: BoxDecoration(
//                           color: kMainColor,
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Center(
//                             child: Icon(
//                           FontAwesomeIcons.plus,
//                           size: 50.0,
//                           color: kBackgroundColor,
//                         )),
//                       ),
//                     ),
//                   );
//                 }
//                 return LayoutBuilder(
//                   builder: (context, constraints) => InkWell(
//                     onTap: () {
//                       // myDialog(title: 'Product $index', price: 10);
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) {
//                         if (constraints.maxWidth > 600) {
//                           return ProductInformation(
//                             productInfo: {
//                               'docId': productsList[index - 1]['docId'],
//                               'name': productsList[index - 1]['name'],
//                               'price': productsList[index - 1]['selling_price'],
//                               'description': productsList[index - 1]
//                                   ['description'],
//                               'image': productsList[index - 1]['image'],
//                               'quantity': productsList[index - 1]['quantity'],
//                               'sell_by': productsList[index - 1]['sell_by'],
//                               'category': productsList[index - 1]['category'],
//                               'cost': productsList[index - 1]['cost_price'],
//                               'product_for': productsList[index - 1]
//                                   ['product_for'],
//                               'minimum': productsList[index - 1]['minimum'],
//                             },
//                           );
//                         } else {
//                           return NewProduct(
//                             isUpdateProduct: true,
//                             info: {
//                               // 'docId': productsList[index - 1]['docId'],
//                               'name': productsList[index - 1]['name'],
//                               'price': productsList[index - 1]['selling_price'],
//                               'description': productsList[index - 1]
//                                   ['description'],
//                               'image': productsList[index - 1]['image'],
//                               'quantity': productsList[index - 1]['quantity'],
//                               'sell_by': productsList[index - 1]['sell_by'],
//                               'category': productsList[index - 1]['category'],
//                               'cost': productsList[index - 1]['cost_price'],
//                               'product_for': productsList[index - 1]
//                                   ['product_for'],
//                               'minimum': productsList[index - 1]['minimum'],
//                             },
//                           );
//                         }
//                       }));
//                     },
//                     child: LayoutBuilder(
//                       builder: (context, constraints) => Container(
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10.0),
//                               child: CachedNetworkImage(
//                                 width: double.infinity,
//                                 fit: BoxFit.fitWidth,
//                                 imageUrl: productsList[index - 1]['image'],
//                                 placeholder: (context, url) {
//                                   return Image.asset(
//                                     'assets/default.jpg',
//                                     width: double.infinity,
//                                   );
//                                 },
//                                 errorWidget: (context, url, widget) {
//                                   return Image.asset(
//                                     'assets/default.jpg',
//                                     width: double.infinity,
//                                   );
//                                 },
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.bottomCenter,
//                               child: Container(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(5.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(productsList[index - 1]['name'],
//                                           style: TextStyle(
//                                               color: kBackgroundColor,
//                                               fontWeight: FontWeight.bold)),
//                                       Text(
//                                         '${productsList[index - 1]['selling_price']}',
//                                         style: TextStyle(
//                                           color: kBackgroundColor,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 height: 50.0,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: kSubMainColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         height: constraints.maxWidth > 600 ? 100.0 : 20.0,
//                         width: constraints.maxWidth > 600 ? 100.0 : 20.0,
//                         decoration: BoxDecoration(
//                           color: kSubMainColor,
//                           // image: DecorationImage(
//                           //     image: AssetImage('assets/default.jpg'),
//                           //     // NetworkImage(
//                           //     //     '${productsList[index - 1]['image'].split('&token')[0]}'),
//                           //     fit: BoxFit.cover),
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             )
//           : Text('Loading'),
//     );
//   }
// }
// // Agents Product

// // Home Page
// Widget pageTwo() {
//   return SingleChildScrollView(
//     padding: EdgeInsets.all(10.0),
//     child: Column(
//       children: [
//         // SizedBox(
//         //   height: 10.0,
//         // ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [],
//         ),
//         SizedBox(
//           height: 10.0,
//         ),
//         Container(
//           //LimitedBox
//           // maxHeight: 500.0,
//           child: FutureBuilder<QuerySnapshot>(
//               future: new GeneralCrud().getAgentProducts(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final products = snapshot.data!.docs;
//                   List<String> productName = [];
//                   List<Map> productsList = [];
//                   products.forEach((element) {
//                     productsList.add({
//                       'id': element.id,
//                       'name': element.get('name'),
//                       'price': element.get('selling_price'),
//                       'quantity': element.get('quantity'),
//                       'image': element.get('image')
//                     });
//                     productName.add(element.get('name'));
//                     // print(jsonEncode(productsList));
//                   });
//                   return ProductWidget(
//                       productName: productName,
//                       products: products,
//                       productsList: productsList);
//                 }
//                 return Center(child: CircularProgressIndicator());
//               }),
//         ),
//       ],
//     ),
//   );
// }

// // Home Page
// Widget pageThree() {
//   return SingleChildScrollView(
//     padding: EdgeInsets.all(10.0),
//     child: Column(
//       children: [
//         // SizedBox(
//         //   height: 10.0,
//         // ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [],
//         ),
//         SizedBox(
//           height: 10.0,
//         ),
//         Container(
//           //LimitedBox
//           // maxHeight: 500.0,
//           child: FutureBuilder<QuerySnapshot>(
//               future: new GeneralCrud().getArchitectProducts(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final products = snapshot.data!.docs;
//                   List<String> productName = [];
//                   List<Map> productsList = [];
//                   products.forEach((element) {
//                     productsList.add({
//                       'id': element.id,
//                       'name': element.get('name'),
//                       'price': element.get('selling_price'),
//                       'quantity': element.get('quantity'),
//                       'image': element.get('image')
//                     });
//                     productName.add(element.get('name'));
//                     // print(jsonEncode(productsList));
//                   });
//                   return ProductWidget(
//                       productName: productName,
//                       products: products,
//                       productsList: productsList);
//                 }
//                 return Center(child: CircularProgressIndicator());
//               }),
//         ),
//       ],
//     ),
//   );
// }
}
