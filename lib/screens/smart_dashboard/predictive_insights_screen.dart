import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/anomaly_alerts_list.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/forecast_chart.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class PredictiveInsightsScreen extends StatefulWidget {
  final String token;
  const PredictiveInsightsScreen({super.key, required this.token});

  @override
  State<PredictiveInsightsScreen> createState() =>
      _PredictiveInsightsScreenState();
}

class _PredictiveInsightsScreenState extends State<PredictiveInsightsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(LoadPredictions(widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: Text(
          'Predictive Insights',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PredictionsLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "REVENUE FORECAST",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ForecastChart(forecast: data.forecast),
                  const SizedBox(height: 24),
                  Text(
                    "SMART ALERTS",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnomalyAlertsList(alerts: data.alerts),
                ],
              ),
            );
          }
          return const Center(child: Text('Please wait...'));
        },
      ),
    );
  }
}
