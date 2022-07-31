// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:viraeshop_admin/components/styles/colors.dart';
// import 'package:viraeshop_admin/components/styles/text_styles.dart';
// import 'package:viraeshop_admin/configs/configs.dart';
// import 'package:viraeshop_admin/screens/non_inventory_product.dart';
// import 'package:viraeshop_admin/screens/shops.dart';
// import 'package:viraeshop_admin/settings/admin_CRUD.dart';
// import 'package:viraeshop_admin/settings/general_crud.dart';
//
// class NewCustomerPage extends StatefulWidget {
//   final Map userInfo;
//   NewCustomerPage({required this.userInfo});
//
//   @override
//   _NewCustomerPageState createState() => _NewCustomerPageState();
// }
//
// class _NewCustomerPageState extends State<NewCustomerPage> {
//   TextEditingController controller = TextEditingController();
//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     return ModalProgressHUD(
//       inAsyncCall: isLoading,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: Icon(FontAwesomeIcons.chevronLeft),
//             color: kSubMainColor,
//             iconSize: 20.0,
//           ),
//           title: Text(
//             widget.userInfo['name'],
//             style: kAppBarTitleTextStyle,
//           ),
//         ),
//         body: Container(
//           color: kBackgroundColor,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10.0),
//                   child: CachedNetworkImage(
//                       imageUrl: widget.userInfo['image'],
//                       height: 60.0,
//                       width: 60.0,
//                       errorWidget: (context, url, childs) {
//                         return Image.asset('assets/default.jpg');
//                       }),
//                 ),
//                 SizedBox(
//                   height: 10.0,
//                 ),
//                 textField(
//                   controller: controller,
//                   hintText: 'Customer Id',
//                   prefix: Icon(
//                     Icons.tag,
//                     color: kNewTextColor,
//                     size: 20.0,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 10.0,
//                 ),
//                 Card(
//                   elevation: 5.0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Container(
//                     padding: EdgeInsets.all(10.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Name: ${widget.userInfo['name']}',
//                           style: kTotalTextStyle,
//                         ),
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                         Text(
//                           'Email: ${widget.userInfo['email']}',
//                           style: kTotalTextStyle,
//                         ),
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                         Text(
//                           'Password: ${widget.userInfo['password']}',
//                           style: kTotalTextStyle,
//                         ),
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                         Text(
//                           'Mobile: ${widget.userInfo['mobile']}',
//                           style: kTotalTextStyle,
//                         ),
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                         Text(
//                           'Address: ${widget.userInfo['address']}',
//                           style: kTotalTextStyle,
//                         ),
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                         Text(
//                           'Customer Type: ${widget.userInfo['role']}',
//                           style: kTotalTextStyle,
//                         ),
//                         SizedBox(
//                           height: 10.0,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 sendButton(title: 'Accept', onTap: () {
//                   if (controller != null) {
//                     setState(() {
//                       isLoading = false;
//                     });
//                     var data = {
//                       'name': widget.userInfo['name'],
//                       'email': widget.userInfo['email'],
//                       'password': widget.userInfo['password'],
//                       'mobile': widget.userInfo['mobile'],
//                       'address': widget.userInfo['address'],
//                       'role': widget.userInfo['role'],
//                       'image': widget.userInfo['image'],
//                       'id': controller.text,
//                     };
//                     GeneralCrud generalCrud = GeneralCrud();
//                     AdminCrud adminCrud = AdminCrud();
//                     generalCrud
//                         .getUser(
//                       widget.userInfo['email'],
//                       widget.userInfo['role'],
//                     )
//                         .then((value) {
//                       if (value) {
//                         setState(() {
//                           isLoading = false;
//                         });
//                         showDialogBox(
//                           buildContext: context,
//                           msg: 'User Already Exist',
//                         );
//                       } else {
//                         adminCrud.addCustomer('', data).then((added) {
//                           if (added) {
//                             setState(() {
//                               isLoading = false;
//                             });
//                             showDialogBox(
//                               buildContext: context,
//                               msg: 'User created',
//                             );
//                           } else {
//                             setState(() {
//                               isLoading = false;
//                             });
//                             showDialogBox(
//                               buildContext: context,
//                               msg: 'An error occured please try again',
//                             );
//                           }
//                         });
//                       }
//                     });
//                   } else {
//                     setState(() {
//                       isLoading = false;
//                     });
//                     showDialogBox(
//                       buildContext: context,
//                       msg: 'Sorry Profile image is Missing',
//                     );
//                   }
//                 })
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
