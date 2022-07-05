import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class ReusableTile extends StatelessWidget {
  final bool? selected;
  final IconData? icon;
  final String? title;
  final bool? padding;
  final onTap;
  final dynamic ticker;
  const ReusableTile({
    Key? key,
    this.onTap,
    this.icon,
    this.selected = false,
    this.title,
    this.padding = false,
    // ignore: avoid_init_to_null
    this.ticker = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected! ? kSelectedTileColor : null,
        child: ListTile(
          mouseCursor: MouseCursor.defer,
          contentPadding: padding == false
              ? EdgeInsets.only(left: 25.0)
              : EdgeInsets.fromLTRB(40.0, 0.0, 0.0, 0.0),
          selected: selected!,
          // onTap: onTap,
          leading: Icon(
            icon,
            color: kBackgroundColor,
            size: 20.0,
          ),
          trailing: ticker,
          title: padding!
              ? InkWell(
                  child: Row(
                    children: [
                      Icon(
                        Icons.brightness_1,
                        color: kBackgroundColor,
                        size: 10.0,
                      ),
                      SizedBox(
                        width: 7.0,
                      ),
                      Text(
                        title!,
                        style: kDrawerTextStyle2,
                      ),
                    ],
                  ),
                )
              : InkWell(
                  child: Text(
                    title!,
                    style: kDrawerTextStyle2,
                  ),
                ),
        ),
      ),
    );
  }
}
