import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class TierSystemWidget extends StatelessWidget {
  final TierSystem tiers;
  const TierSystemWidget({super.key, required this.tiers});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTierCard("GOLD", tiers.gold, const Color(0xFFFFD700),
              [const Color(0xFFFFD700), const Color(0xFFB8860B)]),
          const SizedBox(width: 12),
          _buildTierCard("SILVER", tiers.silver, Colors.grey,
              [const Color(0xFFC0C0C0), const Color(0xFFA9A9A9)]),
          const SizedBox(width: 12),
          _buildTierCard("BRONZE", tiers.bronze, Colors.brown,
              [const Color(0xFFCD7F32), const Color(0xFFA0522D)]),
          const SizedBox(width: 12),
          _buildTierCard("RISING", tiers.rising, Colors.blue,
              [Colors.blue, Colors.blue.shade700]),
          const SizedBox(width: 12),
          _buildTierCard("NEW", tiers.newTier, const Color(0xFF0CBB8C),
              [const Color(0xFF0CBB8C), const Color(0xFF0A9D75)]),
        ],
      ),
    );
  }

  Widget _buildTierCard(
      String label, TierStat stat, Color color, List<Color> gradient) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.stars, color: Colors.white.withOpacity(0.8), size: 20),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${stat.count}",
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "> ${stat.threshold} Spent",
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
