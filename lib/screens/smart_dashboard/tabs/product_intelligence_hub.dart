import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/product_health_grid.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/report_navigation_grid.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/sparkline_ranking_list.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class ProductIntelligenceHub extends StatelessWidget {
  final String token;
  const ProductIntelligenceHub({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return const Center(child: CircularProgressIndicator());
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
                const SizedBox(height: 24),
                _buildSectionTitle("Product Reports"),
                const SizedBox(height: 12),
                const ReportNavigationGrid(),
                const SizedBox(height: 24),
                _buildRankingsHeader(),
                const SizedBox(height: 12),
                SparklineRankingList(rankings: data.rankings),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Detailed Report (Full Table)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111816),
                      elevation: 0,
                      side: BorderSide(color: Colors.grey[200]!),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      "View Detailed Ranking List",
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 48), // Bottom padding
              ],
            ),
          );
        }
        return const Center(child: Text('Please wait...'));
      },
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
            letterSpacing: 1.5,
            color: Colors.grey[500],
          ),
        ),
        Text(
          'Updated just now',
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
        letterSpacing: 1.5,
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF0CBB8C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(Icons.swap_vert, size: 14, color: Color(0xFF0CBB8C)),
              const SizedBox(width: 4),
              Text(
                "SORT",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0CBB8C),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
