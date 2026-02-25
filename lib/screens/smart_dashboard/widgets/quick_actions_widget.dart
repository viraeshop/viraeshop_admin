import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/predictive_insights_screen.dart';

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
              if (action.label == 'Trends' || action.label == 'Alerts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredictiveInsightsScreen(
                        token: context.read<AnalyticsBloc>().state
                                is BusinessHealthLoaded
                            ? "TOKEN_PLACEHOLDER"
                            : ""),
                  ),
                );
              } else if (action.label == 'Reports') {
                DefaultTabController.of(context)?.animateTo(1);
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
                    color: const Color(0xFF00C896),
                    size: 28,
                  ),
                  const SizedBox(height: 12),
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
        return Icons.insert_chart_outlined;
      case 'Trends':
        return Icons.show_chart;
      case 'Alerts':
        return Icons.warning_amber_rounded;
      default:
        return Icons.widgets;
    }
  }
}
