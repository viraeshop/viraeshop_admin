import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

class IconWidget extends StatelessWidget {
  const IconWidget({super.key, 
    required this.icon,
  });
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
