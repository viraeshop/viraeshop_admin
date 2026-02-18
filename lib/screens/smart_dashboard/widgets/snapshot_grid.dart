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
        childAspectRatio: 1.5,
        children: [
          _buildCard(
            title: "Total Sales",
            value: "৳${snapshot.sales.toStringAsFixed(0)}",
            icon: Icons.attach_money,
            color: const Color(0xFF0CBB8C),
          ),
          _buildCard(
            title: "Orders Today",
            value: "${snapshot.orders}",
            icon: Icons.shopping_bag_outlined,
            color: Colors.blue,
          ),
          _buildCard(
            title: "New Customers",
            value: "+${snapshot.newCustomers}",
            icon: Icons.person_add_outlined,
            color: Colors.purple,
          ),
          _buildCard(
            title: "Delivery Rate",
            value: "${snapshot.deliveryRate}%",
            icon: Icons.local_shipping_outlined,
            color: Colors.orange,
          ),
          _buildCard(
            title: "Processing Rate",
            value: "${snapshot.processingRate}%",
            icon: Icons.inventory_2_outlined,
            color: Colors.teal,
          ),
          _buildCard(
            title: "Est. Margin",
            value: "${snapshot.margin}%",
            icon: Icons.trending_up,
            color: Colors.green,
          ),
        ],
      );
    });
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111816),
            ),
          ),
        ],
      ),
    );
  }
}
