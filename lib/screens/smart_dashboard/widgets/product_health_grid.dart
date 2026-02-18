import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class ProductHealthGrid extends StatelessWidget {
  final ProductHealthStats health;
  const ProductHealthGrid({super.key, required this.health});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildHealthCard(
            "HOT",
            health.hot,
            "+12%",
            const Color(0xFF0CBB8C), // Primary
            Colors.white,
          ),
          const SizedBox(width: 12),
          _buildHealthCard(
            "STEADY",
            health.steady,
            "-0.4%",
            Colors.amber,
            Colors.white,
          ),
          const SizedBox(width: 12),
          _buildHealthCard(
            "COOLING",
            health.cooling,
            "-5.2%",
            Colors.blue,
            Colors.white,
          ),
          const SizedBox(width: 12),
          _buildHealthCard(
            "RISK",
            health.risk,
            "High",
            Colors.orange,
            Colors.white,
          ),
          const SizedBox(width: 12),
          _buildHealthCard(
            "SLEEPING",
            health.sleeping,
            "Crit.",
            Colors.red,
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(
    String label,
    int count,
    String trend,
    Color color,
    Color bgColor,
  ) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
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
                  color: const Color(0xFF111816).withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "$count",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111816),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
