import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';

import '../../components/styles/colors.dart';
import '../../components/styles/text_styles.dart';

class OrderRoutineReportWidget extends StatelessWidget {
  const OrderRoutineReportWidget({
    Key? key,
    required this.orders,
    required this.amount,
    this.due = 0.0,
    this.title = 'Today',
    this.onDue = false,
  }) : super(key: key);

  final num orders;
  final num amount;
  final num due;
  final String title;
  final bool onDue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kSansTextStyleWhite,
        ),
        const SizedBox(
          height: 10.0,
          width: 98.0,
          child: Divider(
            thickness: 3,
            color: kBackgroundColor,
          ),
        ),
        Consumer<OrderProvider>(
          builder: (context, provider, any) {
            if(provider.currentStage == OrderStages.order){
              return Text(
                'Orders  $orders',
                style: kSansTextStyleWhite1,
              );
            } else if(provider.currentStage == OrderStages.processing){
              return Text(
                'Processing  $orders',
                style: kSansTextStyleWhite1,
              );
            }  else if(provider.currentStage == OrderStages.receiving){
              return Text(
                'Received  $orders',
                style: kSansTextStyleWhite1,
              );
            } else {
              return Text(
                'Delivery  $orders',
                style: kSansTextStyleWhite1,
              );
            }
          }
        ),
        const SizedBox(
          height: 5.0,
        ),
        Text(
          'Amount  $amount$bdtSign',
          style: kSansTextStyleWhite1,
        ),
        if(onDue) Text(
          'Due  $amount$bdtSign',
          style: kSansTextStyleWhite1,
        ),
      ],
    );
  }
}