import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/customer_intelligence_screen.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/operations_management_screen.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/product_intelligence_screen.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/live_pulse_widget.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/quick_actions_widget.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/snapshot_grid.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class SmartDashboardScreen extends StatefulWidget {
  static const String path = '/smart_dashboard';
  final String? token;

  const SmartDashboardScreen({super.key, this.token});

  @override
  State<SmartDashboardScreen> createState() => _SmartDashboardScreenState();
}

class _SmartDashboardScreenState extends State<SmartDashboardScreen> {
  late String _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token ?? Hive.box('adminInfo').get('token') ?? '';
    context.read<AnalyticsBloc>().add(LoadBusinessHealth(_token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Match the light background
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Insights',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF111816),
              ),
            ),
            Text(
              '9:41 AM • Viraeshop Admin',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111816)),
        leading: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.dashboard,
                  color: Color(0xFF00C896), size: 20),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF00C896),
              radius: 16,
              child: Text("VA",
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
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
          } else if (state is BusinessHealthLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Today's Snapshot", isLive: true),
                  const SizedBox(height: 16),
                  SnapshotGrid(snapshot: data.snapshot),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Live Pulse"),
                  const SizedBox(height: 16),
                  LivePulseWidget(pulse: data.livePulse),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Quick Actions"),
                  const SizedBox(height: 16),
                  QuickActionsWidget(actions: data.quickActions),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Main Categories"),
                  const SizedBox(height: 16),
                  _buildMainCategoriesGrid(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Top Performers"),
                  const SizedBox(height: 16),
                  _buildTopPerformersList(data.topPerformers),
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

  Widget _buildSectionHeader(String title, {bool isLive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "LIVE",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00C896),
                letterSpacing: 1,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildMainCategoriesGrid(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildCategoryCard(
            "Products", Icons.assignment_turned_in_outlined, Colors.blue, 2.5,
            () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProductIntelligenceScreen(token: _token)));
        }),
        _buildCategoryCard("Customers", Icons.people_alt, Colors.green, 2.5, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CustomerIntelligenceScreen(token: _token)));
        }),
        _buildCategoryCard(
            "Operations", Icons.settings_outlined, Colors.orange, 2.5, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OperationsManagementScreen(token: _token)));
        }),
        _buildCategoryCard("Finance", Icons.payments_outlined, Colors.purple, 2.5,
            () {
          // Placeholder for Finance screen
        }),
      ],
    );
  }

  Widget _buildCategoryCard(String label, IconData icon, Color iconColor,
      double aspectRatio, VoidCallback onTap) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 16) / 2;
      return InkWell(
        onTap: onTap,
        child: Container(
          width: width,
          height: width / aspectRatio,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 20)),
              const SizedBox(width: 12),
              Text(label,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF111816))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTopPerformersList(TopPerformers perf) {
    return Column(
      children: [
        _buildPerformerTile("Top Product", perf.product,
            Icons.phone_android_outlined, const Color(0xFF00C896)),
        const SizedBox(height: 12),
        _buildPerformerTile(
            "Top Customer", perf.customer, Icons.person, Colors.blue),
        const SizedBox(height: 12),
        _buildPerformerTile("Top Delivery", perf.delivery,
            Icons.electric_moped_outlined, Colors.orange),
        const SizedBox(height: 12),
        _buildPerformerTile("Top Processing", perf.processing,
            Icons.kitchen_outlined, const Color(0xFF00C896)),
        const SizedBox(height: 12),
        _buildPerformerTile("Top Order Receiver", "Karim",
            Icons.perm_contact_calendar_outlined, Colors.purple),
      ],
    );
  }

  Widget _buildPerformerTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(value,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111816),
                  fontSize: 14)),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      ),
    );
  }
}
