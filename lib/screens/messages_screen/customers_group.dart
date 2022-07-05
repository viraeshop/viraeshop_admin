// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:vira_infinity/components/styles/colors.dart';
// import 'package:vira_infinity/components/styles/text_styles.dart';
// import 'package:vira_infinity/reusable_widgets/notification_ticker.dart';
// import 'package:vira_infinity/screens/messages_screen/messages.dart';
// import 'package:vira_infinity/screens/messages_screen/users_screen.dart';
// import 'package:vira_infinity/settings/general_crud.dart';

// class CustomersGroupScreen extends StatefulWidget {
//   final Map<String, List> userList;
//   CustomersGroupScreen({required this.userList});

//   @override
//   _CustomersGroupScreenState createState() => _CustomersGroupScreenState();
// }

// class _CustomersGroupScreenState extends State<CustomersGroupScreen> {
//   List<String> users = ['General', 'Agents', 'Architect'];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: Icon(FontAwesomeIcons.chevronLeft),
//           iconSize: 20.0,
//           color: kSubMainColor,
//         ),
//         title: Text(
//           'Chat Screen',
//           style: kTextStyle1,
//         ),
//         centerTitle: true,
//       ),
//       body: Container(
//         color: kBackgroundColor,
//         child: ListView.builder(
//           itemCount: users.length,
//           itemBuilder: (context, i) {
//             return ListTile(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => UsersMessagesScreen(
//                       role: users[i].toLowerCase(),
//                       unread: widget.userList[users[i].toLowerCase()],                              
//                     ),
//                   ),
//                 );
//               },
//               leading: CircleAvatar(
//                 backgroundColor: kSubMainColor,
//                 child: Icon(
//                   Icons.group,
//                   color: kBackgroundColor,
//                 ),
//               ),
//               trailing: widget.userList[users[i].toLowerCase()]!.isNotEmpty
//                       ? NotificationTicker(
//                           value: widget.userList[users[i].toLowerCase()]!.length
//                               .toString(),
//                         )
//                       : Icon(Icons.arrow_right, size: 20.0, color: kBlackColor,),
//               title: Text(
//                 '${users[i]}',
//                 style: kTotalSalesStyle,
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${users[i]} customers chats',
//                     style: kTextStyle1,
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
