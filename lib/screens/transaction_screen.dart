// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:vira_infinity/components/custom_widgets.dart';
// import 'package:vira_infinity/components/styles/colors.dart';
// import 'package:vira_infinity/components/styles/text_styles.dart';
// import 'package:vira_infinity/screens/reciept_screen.dart';

// class TransactionScreen extends StatefulWidget {
//   const TransactionScreen({Key? key}) : super(key: key);

//   @override
//   _TransactionScreenState createState() => _TransactionScreenState();
// }

// class _TransactionScreenState extends State<TransactionScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true,
//         iconTheme: IconThemeData(color: kSelectedTileColor),
//         elevation: 0.0,
//         backgroundColor: kBackgroundColor,
//         title: Text(
//           'Transactions',
//           style: kAppBarTitleTextStyle,
//         ),
//         centerTitle: false,
//         titleTextStyle: kTextStyle1,        
//       ),
//       body: FutureBuilder<QuerySnapshot>(
//           future: FirebaseFirestore.instance.collection('transaction').get(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: Container(
//                   height: 50.0,
//                   width: 50.0,
//                   child: CircularProgressIndicator(
//                     color: kMainColor,
//                   ),
//                 ),
//               );
//             } else if (snapshot.hasData) {
//               final data = snapshot.data!.docs;
//               List transactions = [];
//               data.forEach((element) {
//                 transactions.add(element.data());
//               });
//               return ListView.builder(
//                   itemCount: transactions.length,
//                   shrinkWrap: true,
//                   itemBuilder: (BuildContext context, int i) {
//                     List items = transactions[i]['items'];
//                     String description = items.join(', ');
//                     Timestamp timestamp = transactions[i]['date'];
//                     DateTime date = timestamp.toDate();
//                     // return i == 0
//                     //     ? Padding(
//                     //         padding: const EdgeInsets.all(15.0),
//                     //         child: Column(
//                     //           children: [
//                     //             TextField(
//                     //               decoration: InputDecoration(
//                     //                   prefixIcon: Icon(Icons.search),
//                     //                   labelText: 'Search'),
//                     //             ),
//                     //             SizedBox(height: 20),
//                     //             Text('Date:'),
//                     //             SizedBox(height: 20),
//                     //             ListTile(
//                     //               leading: Icon(Icons.book),
//                     //               title: Text(
//                     //                 'Title goes here',
//                     //                 style:
//                     //                     TextStyle(fontWeight: FontWeight.bold),
//                     //               ),
//                     //               subtitle: Align(
//                     //                 alignment: Alignment.centerLeft,
//                     //                 child: Column(
//                     //                   // shrinkWrap: true,
//                     //                   children: [
//                     //                     Align(
//                     //                         alignment: Alignment.centerLeft,
//                     //                         child: Text('Another content')),
//                     //                     // Text('BUTTON'),
//                     //                     Align(
//                     //                       alignment: Alignment.centerLeft,
//                     //                       child: ButtonBar(
//                     //                           alignment:
//                     //                               MainAxisAlignment.start,
//                     //                           children: [
//                     //                             OutlinedButton(
//                     //                                 onPressed: null,
//                     //                                 child: Row(
//                     //                                   children: [
//                     //                                     Text('User $i'),
//                     //                                     Icon(Icons.person),
//                     //                                   ],
//                     //                                 ))
//                     //                           ]),
//                     //                     ),
//                     //                   ],
//                     //                 ),
//                     //               ),
//                     //               trailing: Text('01:10PM'),
//                     //             ),
//                     //           ],
//                     //         ),
//                     //       )
//                     return Container(
//                       margin: EdgeInsets.all(10.0),
//                       color: kBackgroundColor,
//                       padding: const EdgeInsets.all(8.0),
//                       child: ListTile(
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => RecieptScreen()));
//                         },
//                         leading: Icon(Icons.book),
//                         title: Text(
//                           transactions[i]['price'].toString(),
//                           style: kProductNameStyle,
//                         ),
//                         subtitle: Column(
//                           // shrinkWrap: true,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '$description',
//                               style: kProductNameStyle,
//                             ),
//                             // Text('BUTTON'),
//                             ButtonBar(
//                                 alignment: MainAxisAlignment.start,
//                                 children: [
//                                   OutlinedButton(
//                                       onPressed: null,
//                                       child: Row(
//                                         children: [
//                                           Text(
//                                             '${transactions[i]['adminId']}',
//                                             style: kProductNameStylePro,
//                                           ),
//                                           Icon(Icons.person,
//                                               size: 15.0, color: kMainColor),
//                                         ],
//                                       ))
//                                 ]),
//                           ],
//                         ),
//                         trailing: Text(
//                           '${date.toString().split(':0')[0]}',
//                           style: kProductNameStylePro,
//                         ),
//                       ),
//                     );
//                   });
//             } else {
//               return Center(
//                 child: Text(
//                   'Oops an error occured',
//                   style: kProductNameStyle,
//                 ),
//               );
//             }
//           }),
//     );
//   }
// }
