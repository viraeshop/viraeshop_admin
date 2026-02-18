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
        children: rankings.map((product) => _buildRankItem(product)).toList(),
      ),
    );
  }

  Widget _buildRankItem(ProductRankModel product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text(
              product.rank.toString().padLeft(2, '0'),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: product.rank <= 3
                    ? const Color(0xFF0CBB8C)
                    : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          // Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(
                    product.image ?? "https://via.placeholder.com/40"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & Stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111816),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.grey[600]),
                    children: [
                      const TextSpan(text: "Stock • "),
                      TextSpan(
                        text: "${product.stockLeft} Left",
                        style: TextStyle(
                          color: product.stockLeft < 10
                              ? Colors.orange
                              : const Color(0xFF0CBB8C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sales Count & Sparkline
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${product.totalSold} units",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111816),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                height: 20,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getSpots(product.sparkline),
                        isCurved: true,
                        color: const Color(0xFF0CBB8C),
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF0CBB8C).withOpacity(0.1),
                        ),
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
