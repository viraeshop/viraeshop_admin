import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class AnomalyAlertsList extends StatelessWidget {
  final List<AlertModel> alerts;
  const AnomalyAlertsList({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: alerts.map((alert) => _buildAlertItem(alert)).toList(),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    Color color;
    IconData icon;

    switch (alert.type) {
      case 'stock':
        color = Colors.orange;
        icon = Icons.inventory_2;
        break;
      case 'campaign':
        color = Colors.blue;
        icon = Icons.campaign;
        break;
      case 'performance':
        color = Colors.red;
        icon = Icons.warning;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111816),
                  ),
                ),
                Text(
                  "Priority: ${alert.priority.toUpperCase()}",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
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
