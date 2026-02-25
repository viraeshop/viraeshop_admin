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
          _buildTierCard("Gold", "Rank 1-10", "> ${tiers.gold.threshold}",
              Icons.workspace_premium, const Color(0xFF00C896),
              isHighlight: true),
          const SizedBox(width: 12),
          _buildTierCard("Silver", "Rank 11-30", "> ${tiers.silver.threshold}",
              Icons.military_tech, Colors.grey[600]!,
              isHighlight: false),
          const SizedBox(width: 12),
          _buildTierCard("Bronze", "Rank 31-70", "> ${tiers.bronze.threshold}",
              Icons.stars, Colors.orange,
              isHighlight: false),
        ],
      ),
    );
  }

  Widget _buildTierCard(String title, String rankText, String thresholdText,
      IconData icon, Color color,
      {bool isHighlight = false}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isHighlight ? const Color(0xFF00C896) : Colors.grey[100]!,
            width: isHighlight ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111816),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rankText,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            thresholdText,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isHighlight
                  ? const Color(0xFF00C896)
                  : const Color(0xFF111816),
            ),
          ),
        ],
      ),
    );
  }
}
