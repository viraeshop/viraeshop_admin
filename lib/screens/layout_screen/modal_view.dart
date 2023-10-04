import 'package:flutter/material.dart';
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
    Key? key,
  });

  @override
  State<ModalWidget> createState() => _ModalWidgetState();
}

class _ModalWidgetState extends State<ModalWidget> {
  String newMessages = '';
  String newOrders = '';
  @override
  void initState() {
    // TODO: implement initState
    GeneralCrud().getNotifyInfo('newMessages').listen((event) {
      setState(() {
        newMessages = event.get('totalMessages').toString();
      });
    });
    GeneralCrud().getNotifyInfo('newOrders').listen((event) {
      print(event.exists);
      Provider.of<GeneralProvider>(context, listen: false)
          .updateNewOrder(event.get('totalOrder').toString());
    });
    super.initState();
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
                ),
          appBar: myAppBar(
            notifyOnPress: () {
              Navigator.pushNamed(context, NotificationScreen.path);
            },
            messageOnPress: () {
              Navigator.pushNamed(context, UsersMessagesScreen.path);
            },
            context: context,
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
