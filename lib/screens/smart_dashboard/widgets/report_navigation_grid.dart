import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/detailed_product_report_screen.dart';

class ReportNavigationGrid extends StatelessWidget {
  final String token;
  const ReportNavigationGrid({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return GridView.count(
        crossAxisCount: isWide ? 3 : 2,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.6,
        children: [
          _buildNavCard(context, "Top Selling", Icons.trending_up,
              const Color(0xFF00C896)),
          _buildNavCard(context, "Top Viewed", Icons.visibility, Colors.blue),
          _buildNavCard(
              context, "Top Discounted", Icons.local_offer, Colors.orange),
          _buildNavCard(
              context, "Top Reviewed", Icons.chat_bubble, Colors.amber),
          _buildNavCard(
              context, "Top Returned", Icons.keyboard_return, Colors.red),
          _buildNavCard(context, "Categories", Icons.category, Colors.purple),
        ],
      );
    });
  }

  Widget _buildNavCard(
      BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        String metric = 'sales';
        if (title.contains("Viewed")) metric = 'view';
        if (title.contains("Discounted")) metric = 'discount';
        if (title.contains("Reviewed")) metric = 'rating';
        if (title.contains("Returned")) metric = 'return';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedProductReportScreen(
              token: token,
              metric: metric,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Rank 1-25",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
