import 'package:flutter/material.dart' hide SearchBar;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/appBar/notification_bell.dart';
import 'package:viraeshop_admin/reusable_widgets/appBar/search_bar.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';
import 'package:viraeshop_admin/screens/customers/customers_screen.dart';

import '../non_inventory_items.dart';
import 'package:badges/badges.dart' as badges;

myAppBar({messageOnPress, notifyOnPress, required BuildContext context, required String messageCount}) {
  return AppBar(
    centerTitle: false,
    toolbarHeight: 140.0,
    backgroundColor: kNewMainColor,
    automaticallyImplyLeading: false,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      expandedTitleScale: 1.0,
      title: SizedBox(
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
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
                            icon: Icon(box.isEmpty
                                ? Icons.person_add_alt_outlined
                                : Icons.person),
                            iconSize: 35.0,
                          ),
                        );
                      }),
                  const SizedBox(
                    width: 10,
                  ),
                  ValueListenableBuilder(
                      valueListenable: Hive.box('customer').listenable(),
                      builder: (context, Box box, childs) {
                        String name =
                            box.get('role') != 'general' && box.isNotEmpty
                                ? box.get('businessName', defaultValue: '') +
                                    '(${box.get('name')})'
                                : box.get('name', defaultValue: '');
                        return Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: kDrawerTextStyle2,
                            softWrap: true,
                          ),
                        );
                      }),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AdsProvider>(builder: (context, ads, any) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DropdownButton(
                      value: ads.dropdownValue,
                      dropdownColor: kNewMainColor,
                      iconEnabledColor: kBackgroundColor,
                      //alignment: AlignmentDirectional.bottomCenter,
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text(
                            'General',
                            style: kDrawerTextStyle2,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'agents',
                          child: Text(
                            'Agents',
                            style: kDrawerTextStyle2,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'architect',
                          child: Text(
                            'Architect',
                            style: kDrawerTextStyle2,
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        ads.updateDropdownValue(value ?? '');
                      },
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return const NonInventoryScreen();
                          }),
                        );
                      },
                      child: const ImageIcon(
                        AssetImage('assets/icons/flash.png'),
                        color: kBackgroundColor,
                        size: 25.0,
                      ),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                  ],
                );
              }),
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
          width: 7.0,
        ),
        SearchBar(
          onChange: (value) {},
        ),
        // SizedBox(
        //   width: 10.0,
        // ),
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: 0, end: -12),
          showBadge: true,
          ignorePointer: false,
          onTap: () {},
          badgeContent: Text(
                messageCount,
                style: kDrawerTextStyle2.copyWith(
                  fontSize: 10.0,
                ),
              ),
          badgeAnimation: const badges.BadgeAnimation.slide(
            animationDuration: Duration(seconds: 1),
            //colorChangeAnimationDuration: Duration(seconds: 1),
            loopAnimation: false,
            curve: Curves.fastOutSlowIn,
            colorChangeAnimationCurve: Curves.easeInCubic,
            slideTransitionPositionTween: badges.SlideTween(
              begin: Offset(0, 1),
              end: Offset(0, 0),
            ),
          ),
          badgeStyle: badges.BadgeStyle(
            shape: badges.BadgeShape.circle,
            badgeColor: Colors.red,
            padding: const EdgeInsets.all(5),
            borderRadius: BorderRadius.circular(100),
            elevation: 0,
          ),
          child: IconButton(
            padding: const EdgeInsets.all(5.0),
            onPressed: messageOnPress,
            icon: const Icon(Icons.mail_outline),
            color: kBackgroundColor,
          ),
        ),
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
