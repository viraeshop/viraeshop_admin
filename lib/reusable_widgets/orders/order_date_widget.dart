import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';


class OrderDateWidget extends StatelessWidget {
  const OrderDateWidget({Key? key, required this.date, required this.onTap, required this.color})
      : super(key: key);
  final String date;
  final Color color;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
     padding: const EdgeInsets.only(left: 5.0),
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // const SizedBox(
          //   width: 3.0,
          // ),
          Text(
            date,
            style: kSansTextStyleWhite1,
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
    );
  }
}
