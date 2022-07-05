// import 'package:flutter/material.dart';

// reserve() {
//   return Center(
//     child: LayoutBuilder(
//       builder: (context, constraints) => Container(
//         width: constraints.maxWidth > 600
//             ? MediaQuery.of(context).size.width * 0.40
//             : null,
//         height: MediaQuery.of(context).size.height,
//         margin: EdgeInsets.all(16),
//         decoration: kBoxDecoration,
//         child: Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: Stack(
//             children: [
//               Align(
//                 alignment: Alignment.center,
//                 child: Visibility(
//                     visible: showFields,
//                     child: ListView(
//                       shrinkWrap: true,
//                       children: [
//                         SizedBox(
//                           height: 100,
//                           width: 100,
//                           child: Stack(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(13.0),
//                                 child: Align(
//                                   alignment: Alignment.center,
//                                   child: Container(
//                                     // color: Colors.red,
//                                     width: 100,
//                                     height: 100,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.rectangle,
//                                       image: _imageBG(),
//                                       borderRadius: BorderRadius.circular(10.0),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Align(
//                                   alignment: Alignment.center,
//                                   child: InkWell(
//                                       onTap: () {
//                                         if (kIsWeb) {
//                                           getImageWeb();
//                                         } else {
//                                           selectImage();
//                                         }
//                                       },
//                                       child: Icon(Icons.add_a_photo, size: 30)))
//                             ],
//                           ),
//                         ),
//                         TextField(
//                           controller: productName,
//                           decoration: InputDecoration(
//                               labelText: "Product Name",
//                               hintText: "",
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15))),
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         TextField(
//                           controller: productquantity,
//                           decoration: InputDecoration(
//                               labelText: "Quantity",
//                               hintText: "",
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15))),
//                         ),
//                         SizedBox(
//                           height: 20,
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: costPrice,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                     labelText: "Cost Price",
//                                     hintText: "",
//                                     border: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(15))),
//                               ),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.all(10),
//                             ),
//                             Expanded(
//                               child: TextField(
//                                 controller: sellingPrice,
//                                 keyboardType: TextInputType.number,
//                                 decoration: InputDecoration(
//                                     labelText: "Selling Price",
//                                     hintText: "",
//                                     border: OutlineInputBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(15))),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         TextField(
//                           controller: productDescription,
//                           decoration: InputDecoration(
//                               labelText: "Description",
//                               hintText: "",
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15))),
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         DropdownButtonFormField(
//                           decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(15)),
//                               // labelText: "Quantity",
//                               // hintText: "Quantity",
//                               hintStyle: TextStyle(color: Colors.black87)),
//                           hint: Text(
//                               'Select Customer'), // Not necessary for Option 1
//                           // value: default_pruser,
//                           onChanged: (change_val) {
//                             print(change_val);
//                             setState(() {
//                               selected_pruser = change_val.toString();
//                               // print(selected_verification);
//                             });
//                           },
//                           items: _pr_user_List.map((itm) {
//                             return DropdownMenuItem(
//                               child: new Text(itm),
//                               value: itm,
//                             );
//                           }).toList(),
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         InkWell(
//                           child: Container(
//                             width: MediaQuery.of(context).size.width,
//                             height: 50,
//                             decoration: BoxDecoration(
//                                 color:
//                                     kSelectedTileColor, //Theme.of(context).accentColor,
//                                 borderRadius: BorderRadius.circular(15)),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   "Save",
//                                   style: TextStyle(
//                                       fontSize: 20, color: Colors.white),
//                                 )
//                               ],
//                             ),
//                           ),
//                           onTap: () async {
//                             setState(() {
//                               showFields = false;
//                             });
//                             final progress = ProgressHUD.of(context);
//                             progress!.show();
//                             if (productName.text != '' &&
//                                 productquantity.text != '' &&
//                                 costPrice.text != '' &&
//                                 sellingPrice.text != '' &&
//                                 selected_pruser != '') {
//                               var full_image =
//                                   'images/product_${_uniqueCode}.jpg';
//                               // print(jsonEncode(productData));
//                               if (_imageFile != null || images!.isNotEmpty) {
//                                 //Upload image first
//                                 if (kIsWeb) {
//                                   adminCrud
//                                       .uploadWebImage(images, fileName)
//                                       .then((newImageUrl) {
//                                     print(newImageUrl);
//                                     Map<String, dynamic> productData = {
//                                       'name': productName.text,
//                                       'quantity': productquantity.text,
//                                       'cost_price': costPrice.text,
//                                       'selling_price': sellingPrice.text,
//                                       'description': productDescription.text,
//                                       'added_by': '',
//                                       'product_for':
//                                           selected_pruser.toLowerCase(),
//                                       'added_on':
//                                           currdate.millisecondsSinceEpoch,
//                                       'image': newImageUrl,
//                                     };
//                                     adminCrud
//                                         .addProduct(productData)
//                                         .then((added) {
//                                       print(added);
//                                       if (added) {
//                                         //check if added
//                                         progress.dismiss();
//                                         print("Product Added ");
//                                         _showMyDialog(
//                                             msg: 'Product Added ', title: '');
//                                         setState(() {
//                                           showFields = true;
//                                         });
//                                       } else {
//                                         print('Failed to add');
//                                         progress.dismiss();
//                                         _showMyDialog(msg: 'Failed to add');
//                                         setState(() {
//                                           showFields = true;
//                                         });
//                                       }
//                                     });
//                                   });
//                                 } else {
//                                   adminCrud
//                                       .uploadImage(
//                                           filePath: _imageFile,
//                                           imageName: full_image)
//                                       .then((uploadval) {
//                                     Map<String, dynamic> productData = {
//                                       'name': productName.text,
//                                       'quantity': productquantity.text,
//                                       'cost_price': costPrice.text,
//                                       'selling_price': sellingPrice.text,
//                                       'description': productDescription.text,
//                                       'added_by': '',
//                                       'product_for':
//                                           selected_pruser.toLowerCase(),
//                                       'added_on':
//                                           currdate.millisecondsSinceEpoch,
//                                       'image': uploadval,
//                                     };
//                                     adminCrud
//                                         .addProduct(productData)
//                                         .then((added) {
//                                       print(added);
//                                       if (added) {
//                                         //check if added
//                                         progress.dismiss();
//                                         print("Product Added ");
//                                         _showMyDialog(
//                                             msg: 'Product Added ', title: '');
//                                         setState(() {
//                                           showFields = true;
//                                         });
//                                       } else {
//                                         print('Failed to add');
//                                         progress.dismiss();
//                                         _showMyDialog(msg: 'Failed to add');
//                                         setState(() {
//                                           showFields = true;
//                                         });
//                                       }
//                                     });
//                                   });
//                                 }
//                               } else {
//                                 // image is null
//                                 progress.dismiss();
//                                 setState(() {
//                                   showFields = true;
//                                 });
//                                 _showMyDialog(msg: 'image is not selected');
//                               }
//                             } else {
//                               print('FIelds Cannot Be Empty');
//                               progress.dismiss();
//                               _showMyDialog(msg: 'Fields Cannot Be Empty');
//                               setState(() {
//                                 showFields = true;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     )),
//               ),
//               Center(
//                 child: myLoader(text: 'Loading..', visibility: !showFields),
//               )
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
