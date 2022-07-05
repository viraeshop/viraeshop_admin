// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:vira_infinity/components/styles/colors.dart';
// import 'package:vira_infinity/components/styles/text_styles.dart';
// import 'package:vira_infinity/reusable_widgets/buttons/dialog_button.dart';
// import 'package:vira_infinity/screens/new_non_inventory.dart';

// class SearchProductExpense extends StatelessWidget {
//   SearchProductExpense({Key? key}) : super(key: key);
//   TextEditingController controller = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: Icon(FontAwesomeIcons.chevronLeft),
//           iconSize: 20.0,
//           color: kSubMainColor,
//         ),
//         title: Text(
//           'Search Product expense',
//           style: kTextStyle1,
//         ),
//         centerTitle: false,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width,
//             padding: EdgeInsets.all(12.0),
//             // height: 60.0,            
//             decoration: BoxDecoration(
//               color: kBackgroundColor,
//             ),
//             child: Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   TextField(
//                     controller: controller,
//                     style: kProductNameStylePro,
//                     textAlign: TextAlign.center,
//                     cursorColor: kSubMainColor,
//                     decoration: InputDecoration(
//                       hintText: 'Enter invoice number/Id',
//                       hintStyle: kProductNameStylePro,
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: kSubMainColor),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: kSubMainColor),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: kSubMainColor),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10.0,
//                   ),
//                   DialogButton(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) {
//                             return NewNonInventoryProduct(
//                               invoiceId: controller.text,
//                             );
//                           },
//                         ),
//                       );
//                     },
//                     title: 'Search',
//                   ),
//                 ],
//               ),
//             ),
//           ),          
//         ],
//       ),
//     );
//   }
// }
