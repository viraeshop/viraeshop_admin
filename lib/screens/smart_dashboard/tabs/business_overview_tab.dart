import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/live_pulse_widget.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/quick_actions_widget.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/snapshot_grid.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class BusinessOverviewTab extends StatelessWidget {
  final String token;
  const BusinessOverviewTab({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnalyticsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is BusinessHealthLoaded) {
          final data = state.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                SnapshotGrid(snapshot: data.snapshot),
                const SizedBox(height: 24),
                LivePulseWidget(pulse: data.livePulse),
                const SizedBox(height: 24),
                QuickActionsWidget(actions: data.quickActions),
                // Add Top Performers later if needed by design, though HTML puts it below.
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
              'Business Insights',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            Text(
              'Real-time overview of your store performance',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        // Date/Time pill could go here
      ],
    );
  }
}
