import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class OperationsHealthCard extends StatelessWidget {
  final OpHealthMetrics metrics;
  const OperationsHealthCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "OPERATIONS HEALTH",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey[600],
                ),
              ),
              Icon(Icons.health_and_safety, color: const Color(0xFF0CBB8C)),
            ],
          ),
          const SizedBox(height: 20),
          _buildMetricRow("Delivery Success", metrics.deliverySuccess,
              const Color(0xFF0CBB8C)),
          const SizedBox(height: 16),
          _buildMetricRow(
              "Processing Rate", metrics.processingRate, Colors.blue),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInfoBlock(
                    "Avg Processing Time", "${metrics.avgProcessingHours} hrs"),
              ),
              Expanded(
                child: _buildInfoBlock(
                    "Order Error Rate", "${metrics.orderErrorRate}%"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            Text(
              "${value.toStringAsFixed(1)}%",
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111816),
          ),
        ),
      ],
    );
  }
}
