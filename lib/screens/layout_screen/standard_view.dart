// import 'package:flutter/material.dart';
// import 'package:viraeshop_admin/configs/configs.dart';
// import 'package:viraeshop_admin/reusable_widgets/drawer.dart';
// import 'package:provider/provider.dart';
//
// class StandardView extends StatefulWidget {
//   const StandardView({Key? key}) : super(key: key);
//
//   @override
//   _StandardViewState createState() => _StandardViewState();
// }
//
// class _StandardViewState extends State<StandardView> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//             width: MediaQuery.of(context).size.width * 0.25,
//             child: AppDrawer(
//               isBigScreen: true,
//               newOrders: '',
//               totalMessages: '',
//               receivedOrdersCount: '',
//               processingOrdersCount: '',
//             )),
//         SizedBox(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width * 0.77,
//           child: Consumer<Configs>(builder: (context, configs, widget) {
//             return configs.currentScreen;
//           }),
//         ),
//       ],
//     );
//   }
// }
