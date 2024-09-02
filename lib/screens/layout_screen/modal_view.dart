import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/reusable_widgets/appBar/app_bar.dart';
import 'package:viraeshop_admin/reusable_widgets/drawer.dart';
import 'package:viraeshop_admin/reusable_widgets/tabWidget.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';
import 'package:viraeshop_admin/screens/advert/advert_screen.dart';
import 'package:viraeshop_admin/screens/general_provider.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import '../messages_screen/users_screen.dart';
import '../notification/notification_screen.dart';

class ModalWidget extends StatefulWidget {
  const ModalWidget({
    super.key,
  });

  @override
  State<ModalWidget> createState() => _ModalWidgetState();
}

class _ModalWidgetState extends State<ModalWidget> {
  String newMessages = '';
  String newOrders = '';
  String processingOrdersCount = '';
  String receivedOrdersCount = '';
  String assignedAdminOrderCount = '';
  final adminId = Hive.box('adminInfo').get('adminId', defaultValue: '');
  @override
  void initState() {
    // TODO: implement initState
    GeneralCrud().getNotifyInfo('newMessages').listen((event) {
      setState(() {
        newMessages = event.get('totalMessages').toString();
      });
    });
    GeneralCrud().getNotifyInfo('processingOrdersCount').listen((event) {
      setState(() {
        processingOrdersCount = event.get('totalOrder').toString();
      });
    });
    GeneralCrud().getNotifyInfo('receivedOrdersCount').listen((event) {
      setState(() {
        receivedOrdersCount = event.get('totalOrder').toString();
      });
    });
    GeneralCrud().getNotifyInfo('newOrders').listen((event) {
      Provider.of<GeneralProvider>(context, listen: false)
          .updateNewOrder(event.get('totalOrder').toString());
    });
    GeneralCrud().getNotifyInfo(adminId).listen((event) {
      setState(() {
        assignedAdminOrderCount = event.get('totalOrder').toString();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: LayoutBuilder(
        builder: (context, constraints) => Scaffold(
          drawer: constraints.maxWidth > 600
              ? null
              : AppDrawer(
                  isBigScreen: false,
                  newOrders: newOrders,
                  totalMessages: newMessages,
                  processingOrdersCount: processingOrdersCount,
                  receivedOrdersCount: receivedOrdersCount,
                  assignedProcessingOrderCount: assignedAdminOrderCount,
                ),
          appBar: myAppBar(
            notifyOnPress: () {
              Navigator.pushNamed(context, NotificationScreen.path);
            },
            messageOnPress: () {
              Navigator.pushNamed(context, UsersMessagesScreen.path);
            },
            context: context,
            messageCount: newMessages,
          ),
          body: Consumer<AdsProvider>(builder: (context, ads, childs) {
            if (ads.drawerWidget == 'Advert') {
              return const AdvertScreen();
            }
            return TabWidget(
              category: ads.currentCatg,
              isAll: ads.currentCatg == 'All' ? true : false,
            );
          }),
        ),
      ),
    );
  }
}
