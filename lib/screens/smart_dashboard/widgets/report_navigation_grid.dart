import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/detailed_product_report_screen.dart';

class ReportNavigationGrid extends StatelessWidget {
  const ReportNavigationGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Use 2 columns on narrow, 3 on wide
      final isWide = constraints.maxWidth > 600;
      return GridView.count(
        crossAxisCount: isWide ? 3 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.8,
        children: [
          _buildNavCard(context, "Top Selling", Icons.trending_up,
              const Color(0xFF0CBB8C)),
          _buildNavCard(context, "Top Viewed", Icons.visibility, Colors.blue),
          _buildNavCard(context, "Top Discounted", Icons.sell, Colors.orange),
          _buildNavCard(context, "Top Reviewed", Icons.reviews, Colors.amber),
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
              token: "",
              metric: metric,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            Text(
              "Rank 1-25",
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
