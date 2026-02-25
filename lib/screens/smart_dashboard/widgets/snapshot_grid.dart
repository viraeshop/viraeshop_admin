import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class SnapshotGrid extends StatelessWidget {
  final DashboardSnapshot snapshot;
  const SnapshotGrid({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return GridView.count(
        crossAxisCount: isWide ? 3 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
        children: [
          _buildCard(
            title: "SALES",
            value: "৳${snapshot.sales.toStringAsFixed(0)}",
            trend: snapshot.salesTrend ?? "+0%",
            trendPrefix: Icons.trending_up,
            trendColor: const Color(0xFF00C896),
          ),
          _buildCard(
            title: "ORDERS",
            value: "${snapshot.orders}",
            trend: snapshot.ordersTrend ?? "+0%",
            trendPrefix: Icons.trending_up,
            trendColor: const Color(0xFF00C896),
          ),
          _buildCard(
            title: "DELIVERY RATE",
            value: "${snapshot.deliveryRate}%",
            trend: snapshot.deliveryTrend ?? "Target met",
            trendPrefix: Icons.check_circle,
            trendColor: const Color(0xFF00C896),
          ),
          _buildCard(
            title: "PROCESSING RATE",
            value: "${snapshot.processingRate}%",
            trend: snapshot.processingTrend ?? "Optimal",
            trendPrefix: Icons.eco,
            trendColor: const Color(0xFF00C896),
          ),
          _buildCard(
            title: "MARGINS",
            value: "${snapshot.margin}%",
            trend: snapshot.marginTrend ?? "+0%",
            trendPrefix: Icons.trending_up,
            trendColor: const Color(0xFF00C896),
          ),
          _buildCard(
            title: "CUSTOMERS",
            value: "${snapshot.newCustomers}",
            trend: snapshot.customersTrend ?? "New today",
            trendPrefix: Icons.group_add,
            trendColor: const Color(0xFF00C896),
          ),
        ],
      );
    });
  }

  Widget _buildCard({
    required String title,
    required String value,
    required String trend,
    required IconData trendPrefix,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111816),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(trendPrefix, color: trendColor, size: 12),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
