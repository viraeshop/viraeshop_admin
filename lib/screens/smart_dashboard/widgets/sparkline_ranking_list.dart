import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class SparklineRankingList extends StatelessWidget {
  final List<ProductRankModel> rankings;
  const SparklineRankingList({super.key, required this.rankings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: rankings.map((product) => _buildRankItem(product)).toList(),
      ),
    );
  }

  Widget _buildRankItem(ProductRankModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[50]!)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text(
              product.rank.toString().padLeft(2, '0'),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: product.rank == 1
                    ? const Color(0xFF00C896)
                    : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Image
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[100],
              image: DecorationImage(
                image: NetworkImage(
                    product.image ?? "https://via.placeholder.com/44"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111816),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.grey[500]),
                    children: [
                      const TextSpan(text: "Category • "),
                      TextSpan(
                        text: "${product.stockLeft} Left",
                        style: const TextStyle(
                          color: Color(0xFF00C896),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Sales Count & Sparkline
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${product.totalSold >= 1000 ? (product.totalSold / 1000).toStringAsFixed(1) + 'k' : product.totalSold} units",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111816),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 48,
                height: 20,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getSpots(product.sparkline),
                        isCurved: true,
                        color: const Color(0xFF00C896).withOpacity(0.5),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots(List<dynamic> data) {
    if (data.isEmpty) return [];
    return data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value as num).toDouble()))
        .toList();
  }
}
