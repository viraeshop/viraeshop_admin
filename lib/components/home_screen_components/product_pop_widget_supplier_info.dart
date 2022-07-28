import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class SupplierInfo extends StatefulWidget {
  const SupplierInfo({Key? key}) : super(key: key);

  @override
  State<SupplierInfo> createState() => _SupplierInfoState();
}

class _SupplierInfoState extends State<SupplierInfo> {
  bool isAnimate = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Supplier',
              style: kProductNameStylePro,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isAnimate = !isAnimate;
                });
              },
              icon: Icon(
                isAnimate
                    ? FontAwesomeIcons.chevronUp
                    : FontAwesomeIcons.chevronDown,
              ),
              color: kSubMainColor,
              iconSize: 20.0,
            ),
          ],
        ),
        AnimatedContainer(
          height: isAnimate ? 200.0 : 0.0,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  // leading: CircleAvatar(
                  //   backgroundColor: kBackgroundColor,
                  //   radius: 40.0,
                   leading: Icon(
                      Icons.person,
                      color: kSubMainColor,
                      size: 40.0,
                   // ),
                  ),
                  title: Text(
                    'Nazmul Enterprise',
                    style: kProductNameStylePro,
                  ),
                  subtitle: Text(
                    'Mr Kabir',
                    style: kProductNameStylePro,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.call,
                    color: kSubMainColor,
                    size: 20.0,
                  ),
                  title: Text(
                    '+880-904278489',
                    style: kProductNameStylePro,
                  ),
                  subtitle: Text(
                    '+880-904278489',
                    style: kProductNameStylePro,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.storefront,
                    color: kSubMainColor,
                    size: 20.0,
                  ),
                  title: Text(
                    'New Airport road Banani, Dhaka 1213, Bangladesh',
                    style: kProductNameStylePro,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
