import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/detailed_product_report_screen.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/product_health_grid.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/report_navigation_grid.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/sparkline_ranking_list.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class ProductIntelligenceScreen extends StatefulWidget {
  final String token;
  const ProductIntelligenceScreen({super.key, required this.token});

  @override
  State<ProductIntelligenceScreen> createState() =>
      _ProductIntelligenceScreenState();
}

class _ProductIntelligenceScreenState extends State<ProductIntelligenceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(LoadProductIntelligence(widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Product Intelligence",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111816),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00C896),
        shape: const CircleBorder(),
        child: const Icon(Icons.show_chart, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: _buildTopPills(),
          ),
          Expanded(
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF00C896)));
                } else if (state is AnalyticsError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is ProductIntelligenceLoaded) {
                  final data = state.data;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 16),
                        ProductHealthGrid(health: data.health),
                        const SizedBox(height: 32),
                        _buildSectionTitle("PRODUCT INTELLIGENCE REPORTS"),
                        const SizedBox(height: 16),
                        ReportNavigationGrid(token: widget.token),
                        const SizedBox(height: 32),
                        _buildRankingsHeader(),
                        const SizedBox(height: 16),
                        SparklineRankingList(rankings: data.rankings),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedProductReportScreen(
                                    token: widget.token,
                                    metric: 'sales',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF111816),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: Text(
                              "View Detailed Ranking List",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Please wait...'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildPill("Top 10", true, null),
          const SizedBox(width: 12),
          _buildPill("Top 50", false, null),
          const SizedBox(width: 12),
          _buildPill("Top 100", false, null),
          const SizedBox(width: 12),
          _buildPill("Favorites", false, Icons.star),
        ],
      ),
    );
  }

  Widget _buildPill(String label, bool isSelected, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00C896) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? const Color(0xFF00C896) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 14,
                color: isSelected ? Colors.white : const Color(0xFF111816)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF111816),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'HEALTH DASHBOARD',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.grey[500],
          ),
        ),
        Text(
          'Updated 2m ago',
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildRankingsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Performance Rankings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111816),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00C896).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Icon(Icons.swap_vert, size: 14, color: Color(0xFF00C896)),
              const SizedBox(width: 4),
              Text(
                "SORT",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00C896),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
