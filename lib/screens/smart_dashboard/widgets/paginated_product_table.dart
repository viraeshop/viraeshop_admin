import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class PaginatedProductTable extends StatelessWidget {
  final List<DetailedProductReportItem> items;
  final String metric;

  const PaginatedProductTable(
      {super.key, required this.items, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Top 100 Products",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey[200]),
          _buildHeaderRow(),
          Divider(height: 1, color: Colors.grey[200]),
          ...items.take(5).map((e) => _buildRow(e)).toList(),
          const SizedBox(height: 16),
          _buildPaginationIndicator(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "RANK",
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              "PRODUCT",
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "SALES",
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "REVENUE",
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(DetailedProductReportItem item) {
    // Generate rank circle colors based on rank
    Color rankColor = Colors.grey[100]!;
    Color rankTextColor = Colors.grey[800]!;
    if (item.rank == 1) {
      rankColor = Colors.amber.withValues(alpha: 0.2);
      rankTextColor = Colors.amber[800]!;
    } else if (item.rank == 2) {
      rankColor = Colors.grey.withValues(alpha: 0.2);
    } else if (item.rank == 3) {
      rankColor = Colors.orange.withValues(alpha: 0.2);
      rankTextColor = Colors.orange[800]!;
    }

    // Format rating and reviews
    String reviewsText = item.reviewsCount >= 1000
        ? "${(item.reviewsCount / 1000).toStringAsFixed(1)}k"
        : "${item.reviewsCount}";
    String ratingStr = "${item.rating.toStringAsFixed(1)} ($reviewsText)";

    // Format sales (e.g., 2100 -> 2.1k)
    String salesText = "${item.value}";
    if (item.value is num && item.value >= 1000) {
      salesText = "${(item.value / 1000).toStringAsFixed(1)}k";
    }

    // Format revenue (e.g., 24500000 -> 24.5M)
    String revText = "৳${item.revenue}";
    if (item.revenue >= 1000000) {
      revText = "৳${(item.revenue / 1000000).toStringAsFixed(1)}M";
    } else if (item.revenue >= 1000) {
      revText = "৳${(item.revenue / 1000).toStringAsFixed(1)}k";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: rankColor),
              child: Text(
                "${item.rank}",
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: rankTextColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111816),
                      fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      ratingStr,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500]),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              salesText,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111816),
                  fontSize: 13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              revText,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00C896),
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPageNode("<", false),
            _buildPageNode("1", true),
            _buildPageNode("2", false),
            _buildPageNode("3", false),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("...", style: TextStyle(color: Colors.grey)),
            ),
            _buildPageNode("10", false),
            _buildPageNode(">", false),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Showing 1 - 5 of 100 products",
          style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
        )
      ],
    );
  }

  Widget _buildPageNode(String lbl, bool active) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00C896) : Colors.white,
        shape: BoxShape.circle,
        border: active ? null : Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        lbl,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          color: active ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }
}
