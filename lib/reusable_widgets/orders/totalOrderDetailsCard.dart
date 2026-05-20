import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

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
    return Column(
      children: [
        // TODAY CARD (Full Width for Icon + Stats)
        _buildFloatingCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Image.asset(
                  'assets/orders/orders.png',
                  height: 45.0,
                  width: 45.0,
                  color: Colors.black, // Force black color if it's a template
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: OrderRoutineReportWidget(
                  orders: dailyOrders,
                  amount: dailyAmount,
                  title: 'Today',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        // WEEKLY & MONTHLY CARDS (Side-by-Side)
        Row(
          children: [
            Expanded(
              child: _buildFloatingCard(
                child: OrderRoutineReportWidget(
                  orders: weeklyOrders,
                  amount: weeklyAmount,
                  title: 'Weekly',
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildFloatingCard(
                child: OrderRoutineReportWidget(
                  orders: monthlyOrders,
                  amount: monthlyAmount,
                  title: 'Monthly',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: kNewMainColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

