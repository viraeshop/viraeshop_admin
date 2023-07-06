import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/general/profile_image.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/orderRoutineReportWidget.dart';

class CustomerOrderInfoCard extends StatelessWidget {
  const CustomerOrderInfoCard(
      {Key? key, required this.customerInfo, required this.orderInfo})
      : super(key: key);
  final Map<String, dynamic> customerInfo;
  final Map<String, dynamic> orderInfo;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.0,
      width: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: kNewMainColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileImage(),
                Text(
                  'Mobile: ${customerInfo['mobile']}',
                  style: kSansTextStyleWhite1,
                ),
                Text(
                  'Email: ${customerInfo['email']}',
                  style: kSansTextStyleWhite1,
                ),
                Text(
                  'Address: ${customerInfo['address']}',
                  //softWrap: true,
                  //overflow: TextOverflow.ellipsis,
                  style: kSansTextStyleWhite1,
                ),
              ],
            ),
          ),
          OrderRoutineReportWidget(
            orders: orderInfo['total'],
            amount: orderInfo['amount'],
            onDue: true,
            due: orderInfo['due'] ?? 0,
          )
        ],
      ),
    );
  }
}
