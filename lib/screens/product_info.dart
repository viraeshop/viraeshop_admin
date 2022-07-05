import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/decoration.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/desktop_product_cards.dart';
import 'package:viraeshop_admin/reusable_widgets/desktop_product_cards2.dart';
import 'package:viraeshop_admin/reusable_widgets/form_field.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

// class ProductInfo extends StatefulWidget {
//   final Map<String, dynamic> product;
//   ProductInfo({
//     Key? key,
//     required this.product,
//   }) : super(key: key);

//   @override
//   _ProductInfoState createState() => _ProductInfoState();
// }

// class _ProductInfoState extends State<ProductInfo> {
//   var fetchedData;
//   GeneralCrud generalCrud = GeneralCrud();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: LayoutBuilder(
//           builder: (context, constraints) => Container(
//             width: constraints.maxWidth > 600
//                 ? MediaQuery.of(context).size.width * 0.40
//                 : null,
//             height: MediaQuery.of(context).size.height,
//             margin: EdgeInsets.all(16),
//             decoration: kBoxDecoration,
//             child: Stack(
//               children: [
//                 ListView(
//                   shrinkWrap: true,
//                   children: [
//                     SizedBox(
//                       height: 250,
//                       child: Container(
//                         height: 250,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.only(
//                               bottomLeft: Radius.circular(30),
//                               bottomRight: Radius.circular(30)),
//                           color: Colors.white60,
//                           image: DecorationImage(
//                               image: NetworkImage('${widget.product["image"]}'),
//                               fit: BoxFit.cover),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 30,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 0, horizontal: 15),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               'VIra Infinity',
//                               style: TextStyle(color: Colors.black38),
//                             ),
//                           ),
//                           Expanded(
//                               flex: 1,
//                               child: Align(
//                                   alignment: Alignment.centerRight,
//                                   child: Text('Star')))
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 5, horizontal: 15),
//                       child: Row(
//                         children: [
//                           Text(
//                             '${widget.product['name']}',
//                             style: TextStyle(fontSize: 30),
//                           ),
//                           Expanded(
//                               flex: 1,
//                               child: Align(
//                                   alignment: Alignment.centerRight,
//                                   child: Text(
//                                     '\$${widget.product['price']}',
//                                     style: TextStyle(fontSize: 20),
//                                   )))
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 0, horizontal: 15),
//                       child: Text(
//                         'Description',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                       child: Text(
//                         '${widget.product['description']}.',
//                         style: TextStyle(color: Colors.black38),
//                       ),
//                     )
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: InkWell(
//                       child: Container(
//                         padding: EdgeInsets.all(15),
//                         decoration: BoxDecoration(
//                             color: kMainColor, //Theme.of(context).accentColor,
//                             borderRadius: BorderRadius.circular(15)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Add To Cart",
//                               style:
//                                   TextStyle(fontSize: 20, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                       onTap: () {
//                         // Navigator.pop(context);
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class ProductInformation extends StatefulWidget {
  ProductInformation({required this.productInfo});
  final Map<String, dynamic> productInfo;
  @override
  _ProductInformationState createState() => _ProductInformationState();
}

class _ProductInformationState extends State<ProductInformation> {
  AdminCrud adminCrud = AdminCrud();
  final bool isProduct = Hive.box('adminInfo').get('isProduct');
  @override
  Widget build(BuildContext context) {
    final TextEditingController descController =
        TextEditingController(text: widget.productInfo['description']);
    final TextEditingController _nameController =
        TextEditingController(text: widget.productInfo['name']);
    final TextEditingController _priceController =
        TextEditingController(text: widget.productInfo['price'].toString());
    final TextEditingController _costController =
        TextEditingController(text: widget.productInfo['cost']);
    final TextEditingController _quantityController =
        TextEditingController(text: widget.productInfo['quantity'].toString());
    final TextEditingController _minimumController =
        TextEditingController(text: widget.productInfo['minimum'].toString());
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            FontAwesomeIcons.chevronLeft,
            color: kSubMainColor,
          ),
        ),
        title: Text(
          widget.productInfo['name'],
          style: kAppBarTitleTextStyle,
        ),
        titleSpacing: 1.5,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(40.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  DesktopProductCard2(
                    costController: _costController,
                    nameController: _nameController,
                    priceController: _priceController,
                    fromInfo: true,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    // margin: EdgeInsets.all(10.0),
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15.0, top: 15.0),
                          child: Text(
                            'Stocks',
                            style: kCategoryNameStyle,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: kScaffoldBackgroundColor,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Consumer<Configs>(
                            builder: (context, configs, childs) => Column(
                              children: [
                                HeadingTextField(
                                  onMaxLine: false,
                                  controller: _quantityController,
                                  heading: 'Quantity: ',
                                  enable: configs.enableFields,
                                ),
                                HeadingTextField(
                                  onMaxLine: false,
                                  controller: _minimumController,
                                  heading: 'Minimum: ',
                                  enable: configs.enableFields,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 30.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: kBackgroundColor,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 15.0, top: 15.0),
                                  child: Text(
                                    'Product Image',
                                    style: kCategoryNameStyle,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Divider(
                                    color: kScaffoldBackgroundColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.25,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image:
                                      NetworkImage(widget.productInfo['image']),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: kBackgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 15.0, left: 15.0),
                          child: Text(
                            'Description',
                            style: kCategoryNameStyle,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: kScaffoldBackgroundColor,
                          ),
                        ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        Container(
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              // border: Border.all(
                              //   color: kScaffoldBackgroundColor,
                              // ),
                              ),
                          height: MediaQuery.of(context).size.height * 0.20,
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Center(
                            child: Consumer<Configs>(
                              builder: (context, configs, childs) =>
                                  TextFormField(
                                enabled: configs.enableFields,
                                controller: descController,
                                cursorColor: kMainColor,
                                style: kProductNameStylePro,
                                textInputAction: TextInputAction.done,
                                maxLines: 10,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: kMainColor),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: kMainColor),
                                  ),
                                  focusColor: kMainColor,
                                ),
                                // onFieldSubmitted: (value) {
                                //   setState(() => {isEditable = false, title = value});
                                // }
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  InkWell(
                    child: Container(
                      // padding: EdgeInsets.all(15),
                      // margin: EdgeInsets.all(15.0),
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 35.0,
                      decoration: BoxDecoration(
                          color: kIconColor1, //Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          "Edit",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    onTap: isProduct == false ? null : () {
                      bool enable = false;
                      Provider.of<Configs>(context, listen: false)
                          .enable(!enable);
                      setState(() {
                        enable = !enable;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  Consumer<Configs>(
                    builder: (context, configs, childs) => InkWell(
                      child: Container(
                        // padding: EdgeInsets.all(15),
                        // margin: EdgeInsets.all(15.0),
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: 30.0,
                        decoration: BoxDecoration(
                            color: kMainColor, //Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                          child: Text(
                            "Save",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      onTap: () {
                        final progress = ProgressHUD.of(context);
                        progress!.show();
                        Map<String, dynamic> fields = {
                          'name': _nameController.text,
                          'description': descController.text,
                          'category': 'Arcylic Sheets',
                          'selling_price': _priceController.text,
                          'cost_price': _costController.text,
                          'quantity': _quantityController.text,
                          'sell_by': configs.sellBy,
                          'minimum': _minimumController.text,
                          'product_for': configs.productFor,
                          // 'image': productImage,
                        };
                        adminCrud
                            .addProduct(fields, _nameController.text)
                            .then((added) {
                          if (added) {
                            progress.dismiss();
                            showDialogBox(
                              buildContext: context,
                              msg: 'Product Created',
                            );
                          } else {
                            progress.dismiss();
                            showDialogBox(
                              buildContext: context,
                              msg: 'An error occured please try again',
                            );
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField formTextField({required String initialValue, labelText}) {
    return TextFormField(
      cursorColor: kMainColor,
      initialValue: initialValue,
      style: kTextFieldHeadingStyle,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: kTextFieldHeadingStyle,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kMainColor),
        ),
        focusColor: kMainColor,
      ),
    );
  }
}

// Widget reserver (){
//   return Center(
//         child: LayoutBuilder(
//           builder: (context, constraints) => Container(
//             width: constraints.maxWidth > 600
//                 ? MediaQuery.of(context).size.width * 0.40
//                 : null,
//             height: MediaQuery.of(context).size.height,
//             margin: EdgeInsets.all(16),
//             decoration: kBoxDecoration,
//             child: Stack(
//               children: [
//                 ListView(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(15.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             height: 30.0,
//                             width: 30.0,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10.0),
//                               color: kSubMainColor,
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10.0,
//                           ),
//                           Container(
//                             height: 100.0,
//                             width: 100.0,
//                             decoration: BoxDecoration(
//                               image: widget.productInfo['image'] == null
//                                   ? DecorationImage(
//                                       image: AssetImage('assets/default.jpg'),
//                                       fit: BoxFit.contain)
//                                   : DecorationImage(
//                                       image: NetworkImage(
//                                           widget.productInfo['image']),
//                                       fit: BoxFit.cover),
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             child: Align(
//                               alignment: Alignment.bottomCenter,
//                               child: Container(
//                                 color: kSubMainColor,
//                                 height: 40.0,
//                                 width: 100.0,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '\$${widget.productInfo['name']}',
//                                       style: kImageTextStyle,
//                                     ),
//                                     Text(
//                                       widget.productInfo['price'],
//                                       style: kImageTextStyle,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 10.0,
//                           ),
//                           Container(
//                             height: 30.0,
//                             width: 30.0,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10.0),
//                               image: DecorationImage(
//                                 image: AssetImage('assets/default.jpg'),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       color: kBackgroundColor,
//                       padding: EdgeInsets.all(15.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           formTextField(
//                             initialValue: widget.productInfo['name'],
//                             labelText: 'Product name',
//                           ),
//                           SizedBox(
//                             height: 15.0,
//                           ),
//                           formTextField(
//                             initialValue: '${widget.productInfo['prie']}.00',
//                             labelText: 'Price',
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(15.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Details',
//                             style: kAppBarTitleTextStyle,
//                           ),
//                           formTextField(
//                               initialValue: widget.productInfo['description'],
//                               labelText: 'Description'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: InkWell(
//                       child: Container(
//                         padding: EdgeInsets.all(15),
//                         decoration: BoxDecoration(
//                             color: kMainColor, //Theme.of(context).accentColor,
//                             borderRadius: BorderRadius.circular(15)),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Save",
//                               style:
//                                   TextStyle(fontSize: 20, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                       onTap: () {
//                         // Navigator.pop(context);
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
// }