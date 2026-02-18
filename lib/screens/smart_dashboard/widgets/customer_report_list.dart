import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerReportList extends StatelessWidget {
  const CustomerReportList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildReportItem(
            "VIP Customers", "Top 5% spenders", Icons.diamond, Colors.purple),
        const SizedBox(height: 12),
        _buildReportItem("At Risk", "Haven't ordered in 30 days",
            Icons.warning_amber, Colors.orange),
        const SizedBox(height: 12),
        _buildReportItem("Active Users", "Ordered in last 7 days", Icons.people,
            Colors.blue),
      ],
    );
  }

  Widget _buildReportItem(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111816),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
