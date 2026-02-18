import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/predictive_insights_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction> actions;
  const QuickActionsWidget({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return InkWell(
            onTap: () {
              // Navigation Logic
              if (action.label == 'Trends' || action.label == 'Alerts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredictiveInsightsScreen(
                        token: context.read<AnalyticsBloc>().state
                                is BusinessHealthLoaded
                            ? (context.read<AnalyticsBloc>().state
                                        as BusinessHealthLoaded)
                                    .data
                                    .quickActions
                                    .isNotEmpty
                                ? "TOKEN_PLACEHOLDER"
                                : "" // simplified logic
                            : ""), // Ideally pass token from parent or AuthBloc
                  ),
                );
              } else if (action.label == 'Reports') {
                // Switch tabs to Product Hub? Or specific screen?
                // For now, let's navigate to Product Hub via TabController if possible,
                // or just show snackbar as it's a tab.
                // Better: Navigate to Detailed Report directly as a shortcut?
                // Let's stick to Predictive for Trends/Alerts as requested.
                DefaultTabController.of(context)
                    ?.animateTo(1); // Switch to Products Tab
              }
            },
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIcon(action.label),
                    color: const Color(0xFF0CBB8C),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111816),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String label) {
    switch (label) {
      case 'Reports':
        return Icons.bar_chart;
      case 'Trends':
        return Icons.trending_up;
      case 'Alerts':
        return Icons.notifications_active;
      default:
        return Icons.widgets;
    }
  }
}
