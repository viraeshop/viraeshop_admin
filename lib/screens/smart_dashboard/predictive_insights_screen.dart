import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Predictive Insights',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF111816)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF111816)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C896)));
          } else if (state is AnalyticsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PredictionsLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDarkHeroForecast(data.forecast),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Smart Recommendations",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111816),
                        ),
                      ),
                      Text(
                        "Dismiss All",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00C896),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationsList(data.alerts),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const Center(child: Text('Please wait...'));
        },
      ),
    );
  }

  Widget _buildDarkHeroForecast(ForecastModel forecast) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131D1A), // Darker elegant match
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SMART BI FORECAST",
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: const Color(0xFF00C896)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Color(0xFF00C896), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "AI Active",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: const Color(0xFF00C896)),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Future Forecast",
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Next 7 Days Projected Revenue",
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "BDT ${forecast.next7DaysRevenue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}.00",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  forecast.growthTrend,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF00C896),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _getDayLabel(value.toInt()).toUpperCase(),
                                style: GoogleFonts.inter(
                                  color:
                                      value.toInt() == 5 || value.toInt() == 6
                                          ? const Color(0xFF00C896)
                                          : Colors.grey[600],
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          })),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpots(forecast.chartData),
                    isCurved: true,
                    color: const Color(0xFF00C896),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00C896).withValues(alpha: 0.2),
                            const Color(0xFF00C896).withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C896),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("View Full Analysis",
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<AlertModel> alerts) {
    List<Widget> children =
        alerts.map((alert) => _buildRecommendationCard(alert)).toList();
    // Add the AI Confidence Score widget at the very bottom
    children.add(Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF00C896).withValues(alpha: 0.05),
        border:
            Border.all(color: const Color(0xFF00C896).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C896),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text("AI Confidence Score",
                  style:
                      GoogleFonts.inter(fontSize: 13, color: Colors.grey[700])),
            ],
          ),
          Text("94.2%",
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00C896))),
        ],
      ),
    ));
    return Column(children: children);
  }

  Widget _buildRecommendationCard(AlertModel alert) {
    Color ringColor = Colors.blue;
    IconData icon = Icons.lightbulb;
    String actionLabel = "Take Action";
    List<Widget> actionButtons = [];

    if (alert.type == 'stock') {
      ringColor = Colors.deepOrange;
      icon = Icons.inventory_2;
      actionLabel = "Increase Stock";
      actionButtons = [
        _buildActionPill("Ignore", isPrimary: false),
        const SizedBox(width: 8),
        _buildActionPill("Order Now", isPrimary: true),
      ];
    } else if (alert.type == 'campaign') {
      ringColor = Colors.blueAccent;
      icon = Icons.campaign;
      actionLabel = "Launch Campaign";
      actionButtons = [
        _buildActionPill("Dismiss", isPrimary: false),
        const SizedBox(width: 8),
        _buildActionPill("Setup", isPrimary: true),
      ];
    } else if (alert.type == 'performance') {
      ringColor = Colors.purpleAccent;
      icon = Icons.local_offer;
      actionLabel = "Optimize Pricing";
      actionButtons = [
        _buildActionPill("Review Pricing", isPrimary: true),
      ];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ringColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: ringColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(actionLabel,
                        style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF111816))),
                    const SizedBox(height: 6),
                    Text(alert.message,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey[500],
                            height: 1.4)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actionButtons,
          )
        ],
      ),
    );
  }

  Widget _buildActionPill(String text, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF00C896) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isPrimary ? Colors.white : const Color(0xFF111816),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<double> data) {
    if (data.isEmpty) return [];
    // Ensure we only map exactly what we have without overflowing the 0..6 X axis
    return data
        .take(7)
        .toList()
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
  }

  String _getDayLabel(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (index >= 0 && index < 7) return days[index];
    return '';
  }
}
