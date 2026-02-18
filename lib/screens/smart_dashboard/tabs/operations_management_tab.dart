import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/human_resources_card.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/operations_health_card.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class OperationsManagementTab extends StatelessWidget {
  final String token;
  const OperationsManagementTab({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnalyticsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is OperationsHealthLoaded) {
          final data = state.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                OperationsHealthCard(metrics: data.health),
                const SizedBox(height: 24),
                HumanResourcesCard(scorecard: data.employeeScorecard),
                // Additional Widgets like Logistics or Processing Details can go here
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operations Management',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            Text(
              'Monitor delivery and processing efficiency',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
