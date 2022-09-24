import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({Key? key, required this.icon, required this.color, this.onPressed}) : super(key: key);
  final IconData icon;
  final Color color;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
      ),
      color: color,
    );
  }
}
