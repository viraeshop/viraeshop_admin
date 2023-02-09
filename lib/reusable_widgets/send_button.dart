import 'package:flutter/material.dart';

import '../components/styles/colors.dart';
import '../components/styles/text_styles.dart';

class SendButton extends StatelessWidget {
  final void Function() onTap;
  final String title;
  final double? width;
  final Color? color;
  const SendButton({
    required this.onTap,
    required this.title,
    this.width = double.infinity,
    this.color = kNewTextColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50.0,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color,
        ),
        child: Center(
          child: Text(
            title,
            style: kTableHeadingStyle,
          ),
        ),
      ),
    );
  }
}
