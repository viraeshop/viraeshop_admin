import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class LivePulseWidget extends StatelessWidget {
  final LivePulse pulse;
  const LivePulseWidget({super.key, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPulseItem(
            label: "Products",
            status: pulse.productsStatus ?? "Healthy",
            icon: Icons.inventory_2,
            color: const Color(0xFF00C896),
          ),
          const SizedBox(width: 12),
          _buildPulseItem(
            label: "Delivery",
            status: "${pulse.deliveryActive ?? pulse.delivery ?? 0} Active",
            icon: Icons.local_shipping,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildPulseItem(
            label: "Process",
            status: "${pulse.processPending ?? pulse.processing ?? 0} Pend.",
            icon: Icons.sync,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildPulseItem(
            label: "Customers",
            status: "${pulse.customersLive ?? pulse.customers ?? 0} Live",
            icon: Icons.person,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildPulseItem({
    required String label,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111816),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
