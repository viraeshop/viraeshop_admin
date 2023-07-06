import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

import 'orderRoutineReportWidget.dart';

class TotalOrderDetailsCard extends StatelessWidget {
  const TotalOrderDetailsCard({
    Key? key,
    required this.dailyAmount,
    required this.dailyOrders,
    required this.weeklyAmount,
    required this.weeklyOrders,
    required this.monthlyAmount,
    required this.monthlyOrders,
  }) : super(key: key);

  final num dailyOrders;
  final num dailyAmount;
  final num weeklyOrders;
  final num weeklyAmount;
  final num monthlyOrders;
  final num monthlyAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.0,
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: kNewMainColor,
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/orders/orders.png',
                height: 63.0,
                width: 63.0,
              ),
              const SizedBox(width: 10.0),
              OrderRoutineReportWidget(
                orders: dailyOrders,
                amount: dailyAmount,
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OrderRoutineReportWidget(
                orders: weeklyOrders,
                amount: weeklyAmount,
                title: 'Weekly',
              ),
              OrderRoutineReportWidget(
                orders: monthlyOrders,
                amount: monthlyAmount,
                title: 'Monthly',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

