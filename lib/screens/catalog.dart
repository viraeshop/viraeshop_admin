// // import 'dart:html';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_progress_hud/flutter_progress_hud.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:loading_indicator/loading_indicator.dart';
// import 'package:vira_infinity/components/product_table.dart';
// import 'package:vira_infinity/components/styles/colors.dart';
// import 'package:vira_infinity/components/styles/text_styles.dart';
// import 'package:vira_infinity/configs/configs.dart';
// import 'package:vira_infinity/reusable_widgets/product_cards.dart';
// import 'package:vira_infinity/screens/bloc/product_bloc.dart';
// import 'package:vira_infinity/screens/bloc/product_event.dart';
// import 'package:vira_infinity/screens/product_info.dart';
// import 'package:vira_infinity/settings/admin_CRUD.dart';
// import 'package:vira_infinity/settings/general_crud.dart';

// import 'bloc/product_state.dart';

// class Catalog extends StatefulWidget {
//   const Catalog({Key? key}) : super(key: key);

//   @override
//   _CatalogState createState() => _CatalogState();
// }

// class _CatalogState extends State<Catalog> {
//   AdminCrud adminCrud = AdminCrud();
//   GeneralCrud generalCrud = GeneralCrud();
//   @override
//   void initState() {
//     // TODO: implement initState
//     final _callBloc = BlocProvider.of<ProductBloc>(context);
//     _callBloc.add(FetchAllProductEvent());
//     super.initState();
//   }

//   String title = 'All';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 2.0,
//         automaticallyImplyLeading: true,
//         title: Text('Catalog'),
//         titleTextStyle: kProductNameStyle,
//         titleSpacing: 1.0,
//         centerTitle: true,
//         leading: IconButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             icon: Icon(
//               FontAwesomeIcons.chevronLeft,
//               color: kSubMainColor,
//               size: 20.0,
//             )),
//         leadingWidth: 30.0,
//       ),
//       backgroundColor: kBackgroundColor,
//       body: SingleChildScrollView(
//         padding: EdgeInsets.only(
//           // top: 40.0,
//           left: 10.0,
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width * 0.17,
//               height: MediaQuery.of(context).size.height,
//               padding: EdgeInsets.all(10.0),
//               child: ListView(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'New Catalog',
//                         style: kProductNameStyle,
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           createCategoryDialog(
//                             buildContext: context,
//                           );
//                         },
//                         icon: Icon(Icons.add, size: 20.0, color: kIconColor2),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     width: double.infinity,
//                     child: Divider(
//                       color: kScaffoldBackgroundColor,
//                       thickness: 1.0,
//                     ),
//                   ),
//                   StreamBuilder<QuerySnapshot>(
//                       stream: adminCrud.getCategories(),
//                       builder: (context, snapshot) {
//                         if (snapshot.hasData) {
//                           final data = snapshot.data!.docs;
//                           List categories = [];
//                           data.forEach(
//                             (element) {
//                               categories.add(
//                                 element.data(),
//                               );
//                             },
//                           );
//                           return Column(
//                             children: List.generate(categories.length, (index) {
//                               return InkWell(
//                                 onTap: () {
//                                   final _callBloc =
//                                       BlocProvider.of<ProductBloc>(context);
//                                   _callBloc.add(
//                                     FetchProductEvent(
//                                         categoryName: categories[index]
//                                             ['category_name']),
//                                   );
//                                   setState(() {
//                                     title = categories[index]['category_name'];
//                                   });
//                                 },
//                                 child: Container(
//                                   height: 40.0,
//                                   child: Row(
//                                     // mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                     children: [
//                                       Icon(
//                                         Icons.category,
//                                         color: kIconColor1,
//                                         size: 15.0,
//                                       ),
//                                       SizedBox(
//                                         width: 5.0,
//                                       ),
//                                       Text(
//                                         categories[index]['category_name'],
//                                         style: kProductNameStylePro,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }),
//                           );
//                         } else if (snapshot.hasError) {
//                           return Text(
//                             'Opps no category found click on the plus icon to create new',
//                             softWrap: true,
//                             style: kProductNameStylePro,
//                           );
//                         } else {
//                           return Center(
//                             child: CircularProgressIndicator(
//                               color: kMainColor,
//                             ),
//                           );
//                         }
//                       }),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: MediaQuery.of(context).size.height,
//               child: VerticalDivider(),
//             ),
//             Container(
//               padding: EdgeInsets.all(10.0),
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width * 0.79,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       title,
//                       style: kProductNameStylePro,
//                     ),
//                     SizedBox(
//                       height: 20.0,
//                     ),
//                     BlocBuilder<ProductBloc, ProductState>(
//                       builder: (context, state) {
//                         if (state is ProductLoadingState) {
//                           print('Loading');
//                           return Center(
//                             child: CircularProgressIndicator(
//                               color: kMainColor,
//                             ),
//                           );
//                         } else if (state is ProductLoadedState) {
//                           print('Loaded');
//                           List products = state.productList;
//                           List productIds = state.idList;
//                           print('products: $products');
//                           print('products: $productIds');
//                           return LimitedBox(
//                             maxHeight: MediaQuery.of(context).size.height,
//                             child: GridView.builder(
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 5,
//                                 mainAxisSpacing: 5.0,
//                                 crossAxisSpacing: 5.0,
//                                 childAspectRatio: 1 / 1.5,
//                               ),
//                               itemCount: products.length,
//                               itemBuilder: (context, i) {
//                                 return ProductCards(
//                                   productName: products[i]['name'],
//                                   productDescription: products[i]
//                                       ['description'],
//                                   productPrice: products[i]['selling_price'],
//                                   productCategory: products[i]['category'],
//                                   image: products[i]['image'],
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             ProductInformation(
//                                           productInfo: {
//                                             'docId': productIds[i],
//                                             'name': products[i]['name'],
//                                             'price': products[i]
//                                                 ['selling_price'],
//                                             'description': products[i]
//                                                 ['description'],
//                                             'image': products[i]['image'],
//                                             'quantity': products[i]['quantity'],
//                                             'sell_by': products[i]['sell_by'],
//                                             'category': products[i]['category'],
//                                             'cost': products[i]['cost_price'],
//                                             'product_for': products[i]
//                                                 ['product_for'],
//                                             'minimum': products[i]['minimum'],
//                                           },
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                           );
//                         } else {
//                           print('Error');
//                           return Center(
//                             child: Text(
//                               'Opps no category found click on the plus icon to create new',
//                               softWrap: true,
//                               style: kProductNameStylePro,
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
