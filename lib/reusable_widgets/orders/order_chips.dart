import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class OrderChips extends StatelessWidget {
  const OrderChips(
      {Key? key,
      required this.title,
      required this.onTap,
      required this.isSelected,
        this.selectedColor = kNewBrownColor,
        this.unSelectedColor = kNewMainColor,
        this.width,
        this.height,
      })
      : super(key: key);
  final String title;
  final bool isSelected;
  final void Function()? onTap;
  final Color selectedColor;
  final Color unSelectedColor;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(7.0),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unSelectedColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            title,
            style: kSansTextStyleWhite1,
          ),
        ),
      ),
    );
  }
}
