import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

class DialogButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  Color color, borderColor;
  bool isBorder;
  double? radius, width, height;
  DialogButton(
      {required this.onTap,
      required this.title,
      this.color = kSubMainColor,
      this.isBorder = false,
      this.borderColor = kBackgroundColor,
      this.radius = 3.0,
      this.width = 135.0,
        this.height,
      });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius!),
          color: color,
          border: isBorder
              ? Border.all(
                  color: borderColor,
                )
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15.0,
              color: isBorder ? kMainColor : kBackgroundColor,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
