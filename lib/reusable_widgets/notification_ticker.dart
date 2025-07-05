import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class NotificationTicker extends StatelessWidget {
  final String value;
  const NotificationTicker({super.key, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
     height: 30.0,
     width: 30.0,
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(100.0),
       color: kRedColor,
     ), 
     child: Center(
       child: Text(
         value,
         style: kDrawerTextStyle2,
       ),
     ),
    );
  }
}