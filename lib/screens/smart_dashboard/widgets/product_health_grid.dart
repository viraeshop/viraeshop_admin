import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class ProductHealthGrid extends StatelessWidget {
  final ProductHealthStats health;
  const ProductHealthGrid({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildHealthCard(
            "HOT",
            health.hot,
            health.hotTrend,
            const Color(0xFF00C896),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHealthCard(
            "STEADY",
            health.steady,
            health.steadyTrend,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildHealthCard(
            "COOLING",
            health.cooling,
            health.coolingTrend,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthCard(String label, int count, String? trend, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111816),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$count",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111816),
            ),
          ),
          if (trend != null && trend.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              trend,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
