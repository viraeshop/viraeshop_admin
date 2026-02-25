import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/paginated_product_table.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class DetailedProductReportScreen extends StatefulWidget {
  final String token;
  final String metric;

  const DetailedProductReportScreen({
    super.key,
    required this.token,
    this.metric = 'sales',
  });

  @override
  State<DetailedProductReportScreen> createState() =>
      _DetailedProductReportScreenState();
}

class _DetailedProductReportScreenState
    extends State<DetailedProductReportScreen> {
  String _currentMetric = 'sales';

  @override
  void initState() {
    super.initState();
    _currentMetric = widget.metric;
    _loadReport();
  }

  void _loadReport() {
    context.read<AnalyticsBloc>().add(
          LoadProductReport(
            token: widget.token,
            metric: _currentMetric,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Products',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF111816)),
            ),
            Text(
              'VIRAESHOP ANALYTICS',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF111816)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF00C896).withValues(alpha: 0.1),
              radius: 18,
              child: const Icon(Icons.emoji_events,
                  color: Color(0xFF00C896), size: 18),
            ),
          )
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C896)));
          } else if (state is AnalyticsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ProductReportLoaded) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFilterBar(),
                  ),
                  _buildDarkHeroCard(state.data),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: PaginatedProductTable(
                        items: state.data.items, metric: _currentMetric),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const Center(child: Text('Evaluating data...'));
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildDropdownChip("This Month", true),
          _buildDropdownChip("Category", false),
          _buildDropdownChip("Price Range", false),
        ],
      ),
    );
  }

  Widget _buildDropdownChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00C896) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down,
              size: 16, color: isSelected ? Colors.white : Colors.black87),
        ],
      ),
    );
  }

  Widget _buildDarkHeroCard(ProductReportData report) {
    final top3 = report.items.take(3).toList();
    if (top3.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF14251F), // Very dark green/black
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MONTHLY UNITS SOLD",
                style: GoogleFonts.inter(
                  color: Colors.grey[400],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph,
                    color: Color(0xFF00C896), size: 16),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                report.totalSold.toString(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_outward,
                        color: Color(0xFF00C896), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      report.growthPercentage,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00C896),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          ...top3.asMap().entries.map((entry) {
            final item = entry.value;
            final maxVal = top3.first.value;
            final pct = maxVal > 0 ? (item.value / maxVal) : 0.0;
            return _buildHeroListItem(
                item.name.toUpperCase(), item.value.toString(), pct);
          }),
        ],
      ),
    );
  }

  Widget _buildHeroListItem(String title, String value, double pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 8,
                  width: constraints.maxWidth * pct,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
