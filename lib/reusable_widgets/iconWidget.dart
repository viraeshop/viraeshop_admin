import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

class IconWidget extends StatelessWidget {
  const IconWidget({super.key, 
    required this.icon,
    this.onTap,
  });
  final IconData icon;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.0,
        width: 50.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: kBackgroundColor,
        ),
        child: Icon(
          icon,
          color: Colors.black54,
          size: 20.0,
        ),
      ),
    );
  }
}
