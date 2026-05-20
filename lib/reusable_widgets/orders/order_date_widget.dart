import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';


class OrderDateWidget extends StatelessWidget {
  const OrderDateWidget({
    Key? key,
    required this.date,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  final String date;
  final Color color;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15), // Use a lighter version
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: color.withOpacity(0.3), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              date,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 13.0,
              ),
            ),
            const SizedBox(width: 8.0),
            Icon(
              Icons.calendar_today_outlined,
              size: 16.0,
              color: color.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
