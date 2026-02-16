import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_bloc/dashboard/dashboard_bloc.dart';
import 'package:viraeshop_bloc/dashboard/dashboard_event.dart';
import 'package:viraeshop_bloc/dashboard/dashboard_state.dart';

class SuperAdminDashboard extends StatefulWidget {
  static const String path = '/super_admin_dashboard';
  final String token;
  const SuperAdminDashboard({super.key, required this.token});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _newOrders = 0;
  double _totalSales = 0.0;
  double _codPending = 0.0;
  int _processing = 0;
  int _delivery = 0;
  int _delayed = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    context
        .read<DashboardBloc>()
        .add(GetDashboardStatsEvent(token: widget.token));
  }

  void _updateStats(Map<String, dynamic> stats) {
    if (mounted) {
      setState(() {
        _newOrders = stats['newOrdersCount'] ?? 0;
        _totalSales = (stats['totalSales'] ?? 0).toDouble();
        _codPending = (stats['codPending'] ?? 0).toDouble();
        _processing = stats['processingCount'] ?? 0;
        _delivery = stats['deliveryCount'] ?? 0;
        _delayed = stats['delayedCount'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Super Admin"),
        backgroundColor: kNewMainColor,
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) {
            _updateStats(state.stats);
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading && _totalSales == 0) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Stats
                _buildStatCard(
                    "Total Sales",
                    "৳ ${_totalSales.toStringAsFixed(0)}",
                    Colors.green,
                    isDark),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildStatCard(
                            "New Orders", "$_newOrders", Colors.blue, isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildStatCard(
                            "COD Pending",
                            "৳ ${_codPending.toStringAsFixed(0)}",
                            Colors.orange,
                            isDark)),
                  ],
                ),

                const SizedBox(height: 24),

                const Text("Active Operations",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                        child: _buildOperationCard("Processing", "$_processing",
                            Icons.sync, Colors.blue, isDark)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildOperationCard("Delivery", "$_delivery",
                            Icons.local_shipping, kNewMainColor, isDark)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildOperationCard("Delayed", "$_delayed",
                            Icons.warning, Colors.red, isDark)),
                  ],
                ),

                const SizedBox(height: 24),

                // Staff Performance Mockup
                const Text("Staff Performance (Demo)",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                _buildStaffCard("Rafiq Ahmed", 0.98, kNewMainColor, isDark),
                const SizedBox(height: 8),
                _buildStaffCard("Karim Ullah", 0.87, Colors.orange, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildOperationCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStaffCard(
      String name, double performance, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.grey[200], child: Text(name[0])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${(performance * 100).toInt()}%",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                    value: performance,
                    color: color,
                    backgroundColor: Colors.grey[200],
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4))
              ],
            ),
          )
        ],
      ),
    );
  }
}
