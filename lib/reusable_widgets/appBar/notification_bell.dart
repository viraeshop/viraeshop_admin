import 'package:flutter/material.dart';

import '../../components/styles/colors.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({this.onPressed});
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Column(
        children: const [
          CircleAvatar(
            backgroundColor: kRedColor,
            radius: 3.0,
          ),
          // SizedBox(
          //   height: .0,
          // ),
          Icon(
            Icons.notifications_none_outlined,
            size: 30.0,
          ),
        ],
      ),
      iconSize: 38.0,
      color: kBackgroundColor,
    );
  }
}
