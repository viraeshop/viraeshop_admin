import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class EmployeeScorecardScreen extends StatefulWidget {
  final String token;
  const EmployeeScorecardScreen({super.key, required this.token});

  @override
  State<EmployeeScorecardScreen> createState() =>
      _EmployeeScorecardScreenState();
}

class _EmployeeScorecardScreenState extends State<EmployeeScorecardScreen> {
  String _activeTab = 'Monthly';

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(LoadOperationsHealth(widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Performance Scorecard',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 20, color: Color(0xFF111816)),
            onPressed: () {},
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
          } else if (state is OperationsHealthLoaded) {
            final data = state.data.employeeScorecard;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(),
                  const SizedBox(height: 32),
                  _buildCircularProgressIndicator(data),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Core Metrics Breakdown"),
                  const SizedBox(height: 16),
                  _buildCoreMetricsList(data),
                  const SizedBox(height: 32),
                  _buildDownloadButton(),
                  const SizedBox(height: 16),
                  _buildSmartInsightCard(),
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

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['Today', 'Weekly', 'Monthly'].map((tab) {
          final isActive = _activeTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isActive ? const Color(0xFF00C896) : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: GoogleFonts.inter(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive ? const Color(0xFF00C896) : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCircularProgressIndicator(EmployeeScorecard scorecard) {
    int overall =
        ((scorecard.reliability + scorecard.speed + scorecard.accuracy) / 3)
            .round();
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: overall / 100.0,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[100],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF00C896)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    overall.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3246),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    "Out of 100",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Excellent Performance Score",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00C896),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Last updated: 2 mins ago",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3246),
          ),
        ),
        Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
      ],
    );
  }

  Widget _buildCoreMetricsList(EmployeeScorecard scorecard) {
    return Column(
      children: [
        _buildMetricCard(
          icon: Icons.verified_user, // shield-like
          title: "Reliability",
          value: scorecard.reliability,
          subtitle: "System Uptime",
          trend: "+1.2%",
          color: const Color(0xFF00C896),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          icon: Icons.bolt, // lightning
          title: "Speed",
          value: scorecard.speed,
          subtitle: "Response Latency",
          trend: "+0.8%",
          color: const Color(0xFF00C896),
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          icon: Icons.track_changes, // target
          title: "Accuracy",
          value: scorecard.accuracy,
          subtitle: "Error Rate",
          trend: "+0.5%",
          color: const Color(0xFF00C896),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required num value,
    required String subtitle,
    required String trend,
    required Color color,
  }) {
    final isPositive = trend.startsWith("+");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF2C3246),
                    ),
                  ),
                ],
              ),
              Text(
                "${value.toInt()}%",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2C3246),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    trend,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green[500] : Colors.red[500],
                    ),
                  ),
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green[500] : Colors.red[500],
                    size: 12,
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C896),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          "Download Detailed Report",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSmartInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00C896).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF00C896).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(Icons.lightbulb, color: Color(0xFF00C896), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Smart Insight",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: const Color(0xFF00C896))),
                const SizedBox(height: 6),
                Text(
                    "Your reliability score is at an all-time high this week. Focusing on reducing API latency could push your overall score above 90.",
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.5,
                        color: const Color(0xFF2C3246).withValues(alpha: 0.8))),
              ],
            ),
          )
        ],
      ),
    );
  }
}
