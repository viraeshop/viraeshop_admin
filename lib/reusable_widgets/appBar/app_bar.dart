import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/appBar/notification_bell.dart';
import 'package:viraeshop_admin/reusable_widgets/appBar/search_bar.dart';
import 'package:viraeshop_admin/screens/allcustomers.dart';

myAppBar({messageOnPress, notifyOnPress}) {
  return AppBar(
    centerTitle: false,
    toolbarHeight: 130.0,
    backgroundColor: kNewMainColor,
    automaticallyImplyLeading: false,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      expandedTitleScale: 1.0,
      title: SizedBox(
          height: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 20,
            ),
            const Icon(
              Icons.business,
              color: kBackgroundColor,
            ),
            const SizedBox(
              width: 10,
            ),
            ValueListenableBuilder(
                valueListenable: Hive.box('customer').listenable(),
                builder: (context, Box box, childs) {
                  return Text(
                  box.get('name', defaultValue: ''),
                  overflow: TextOverflow.ellipsis,
                  style: kDrawerTextStyle2,
                  softWrap: true,
                );
              }
            ),
          ],
        ),
      ),
    ),
    title: Row(
      children: [
        Builder(
          builder: (BuildContext context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.menu,
              color: kBackgroundColor,
            ),
            iconSize: 35.0,
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        SearchBar(
          onChange: (value) {},
        ),
        // SizedBox(
        //   width: 10.0,
        // ),
        ValueListenableBuilder(
                    valueListenable: Hive.box('customer').listenable(),
                    builder: (context, Box box, childs) {
                        return SizedBox(
                          width: 35,
                          child: IconButton(
                                color: kBackgroundColor,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const CustomersScreen()));
                                },
                                icon: Icon(box.isEmpty ? Icons.person_add_alt_outlined : Icons.person),
                                iconSize: 35.0,
                              ),
                        );

                    }),
        // SizedBox(
        //    width: 20.0,
        //  ),
        NotificationBell(
          onPressed: notifyOnPress,
        ),
      ],
    ),
  );
}
