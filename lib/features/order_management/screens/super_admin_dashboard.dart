import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_bloc/dashboard/dashboard_bloc.dart';
import 'package:viraeshop_bloc/dashboard/dashboard_event.dart';
import 'package:viraeshop_bloc/dashboard/dashboard_state.dart';

class SuperAdminDashboard extends StatefulWidget {
  static const String path = '/super_admin_dashboard';
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  // Real dynamic data stats
  int _newOrders = 0;
  int _newOrdersTrend = 0;

  double _totalSales = 0.0;
  int _totalSalesTrend = 0;

  double _codPending = 0.0;
  int _codPendingTrend = 0;

  int _processing = 0;
  int _delivery = 0;

  int _delayed = 0;
  int _partialPayments = 0;

  int _pendingApproval =
      0; // Using _newOrders as proxy for pending orders alert based on design

  List<dynamic> _dailyPerformance = [];
  List<dynamic> _topPerformers = [];

  // Admin Profile info from Hive
  String _adminName = "Admin";
  String _adminImage = "";

  final token = Hive.box('adminInfo').get('token');

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    _fetchData();
  }

  void _loadAdminInfo() {
    try {
      final box = Hive.box('adminInfo');
      final name = box.get('name');
      final images = box.get('images'); // Assuming it's a list or similar map

      if (name != null) {
        setState(() {
          _adminName = name.toString();
        });
      }

      if (images != null && images is List && images.isNotEmpty) {
        setState(() {
          _adminImage = images[0]['url'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Could not load admin info: $e");
    }
  }

  void _fetchData() {
    context.read<DashboardBloc>().add(GetDashboardStatsEvent(token: token));
  }

  void _updateStats(Map<String, dynamic> stats) {
    if (mounted) {
      setState(() {
        _newOrders = stats['newOrdersCount'] ?? 0;
        _newOrdersTrend = stats['newOrdersTrend'] ?? 0;

        _totalSales = (stats['totalSales'] ?? 0).toDouble();
        _totalSalesTrend = stats['totalSalesTrend'] ?? 0;

        _codPending = (stats['codPending'] ?? 0).toDouble();
        _codPendingTrend = stats['codPendingTrend'] ?? 0;

        _processing = stats['processingCount'] ?? 0;
        _delivery = stats['deliveryCount'] ?? 0;

        _delayed = stats['delayedCount'] ?? 0;
        _partialPayments = stats['partialPaymentsCount'] ?? 0;

        _dailyPerformance = stats['dailyPerformance'] ?? [];
        _topPerformers = stats['topPerformers'] ?? [];

        _pendingApproval =
            _newOrders; // Design says "5 orders waiting for approval" which matches the 5 new orders
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMM yyyy').format(now);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC), // Light off-white background matching design
      appBar: AppBar(
        title: const Text(
          "Viraeshop Admin",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFFE2FBE9), // Light green tint
            child: Icon(Icons.storefront,
                color: Color(0xFF00C896), size: 20),
          ),
        ),
        // NOTE: Strictly no notification bell per requirements.
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) {
            _updateStats(state.stats);
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading && _newOrders == 0) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C896)));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchData();
              return await Future.delayed(const Duration(seconds: 1));
            },
            color: const Color(0xFF00C896),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _adminImage.isNotEmpty
                            ? NetworkImage(_adminImage)
                            : null,
                        child: _adminImage.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, $_adminName",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF00C896),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: IconButton(
                            icon: const Icon(Icons.settings,
                                color: Color(0xFF64748B)),
                            onPressed: () {},
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 2. Pending Orders Alert
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF8), // Very light mint green
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: const Color(0xFFD1FAE5), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C896), // Solid Green
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.priority_high,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Pending Orders Alert",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "You have $_pendingApproval orders waiting for approval.",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C896),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              // Navigate to order approval
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("View Pending Orders",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Stats Grid (Row 1)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          label: "NEW ORDERS",
                          value: "$_newOrders",
                          trend: _newOrdersTrend,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          label: "TOTAL SALES",
                          value:
                              "৳ ${NumberFormat('#,##0').format(_totalSales)}",
                          trend: _totalSalesTrend,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. Stats Grid (Row 2 - Full Width)
                  _buildStatCard(
                    label: "COD COLLECTION PENDING",
                    value: "৳ ${NumberFormat('#,##0').format(_codPending)}",
                    trend: _codPendingTrend,
                    isFullWidth: true,
                    icon: Icons.account_balance_wallet,
                  ),

                  const SizedBox(height: 28),

                  // 5. Active Operations
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Active Operations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00C896),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.sync, size: 16),
                          label: Text("Processing ($_processing)",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.local_shipping, size: 16),
                          label: Text("Out for Delivery ($_delivery)",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6), // Blue
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 6. Daily Chart
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Daily Orders vs Delivered",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Icon(Icons.bar_chart,
                                color: Colors.grey.shade400, size: 24),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 180,
                          child: _buildBarChart(),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildChartLegend(
                                color: const Color(0xFFA7F3D0),
                                label: "Orders"),
                            const SizedBox(width: 24),
                            _buildChartLegend(
                                color: const Color(0xFF00C896),
                                label: "Delivered"),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 7. Staff Performance
                  const Text(
                    "Staff Performance",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Map over real performers
                  ...(_topPerformers.isNotEmpty
                      ? _topPerformers.take(2).map((staff) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildStaffItem(
                              name: staff['name'] ?? 'Unknown',
                              deliveries:
                                  "${staff['deliveriesToday'] ?? 0} Deliveries Today",
                              efficiency: ((double.tryParse(
                                              staff['efficiency'].toString()) ??
                                          0.0) *
                                      100)
                                  .toInt(),
                            ),
                          );
                        }).toList()
                      : [
                          _buildStaffItem(
                              name: "No Active Staff",
                              deliveries: "0 Deliveries Today",
                              efficiency: 0),
                        ]),

                  const SizedBox(height: 24),

                  // 8. Problem Orders
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2), // Light Red tint
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: const Color(0xFFFECACA), width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFDC2626)),
                                SizedBox(width: 8),
                                Text(
                                  "Problem Orders",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626), // Red badge
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_delayed + _partialPayments} Detected",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildProblemRow("Delayed Shipments", "$_delayed"),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Color(0xFFFECACA), height: 1),
                        ),
                        _buildProblemRow(
                            "Partial Payments", "$_partialPayments"),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFECACA)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () {},
                            child: const Text("Review All Issues",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),

                  // Bottom padding
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required int trend,
    bool isFullWidth = false,
    IconData? icon,
  }) {
    final bool isPositive = trend >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF64748B))),
              if (icon != null)
                Icon(icon, color: Colors.grey.shade400, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFE2FBE9)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPositive ? "+$trend%" : "$trend%",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? const Color(0xFF00C896)
                        : const Color(0xFFDC2626),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        )
      ],
    );
  }

  Widget _buildBarChart() {
    if (_dailyPerformance.isEmpty) return const SizedBox.shrink();

    // We expect 5 days of data ideally. If fewer, fl_chart handles it.
    double maxVal = 10; // Default max
    for (var day in _dailyPerformance) {
      if ((day['placed'] ?? 0) > maxVal)
        maxVal = (day['placed'] ?? 0).toDouble();
      if ((day['delivered'] ?? 0) > maxVal)
        maxVal = (day['delivered'] ?? 0).toDouble();
    }

    // Add 20% padding to max chart height
    maxVal = maxVal * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal,
        barTouchData: const BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index < 0 || index >= _dailyPerformance.length) {
                  return const SizedBox.shrink();
                }

                final isToday = index == _dailyPerformance.length - 1;

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _dailyPerformance[index]['day'] ?? '',
                    style: TextStyle(
                      color: isToday
                          ? const Color(0xFF00C896)
                          : const Color(0xFF94A3B8),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade100,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: _dailyPerformance.asMap().entries.map((entry) {
          int index = entry.key;
          var data = entry.value;

          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: (data['placed'] ?? 0).toDouble(),
                color: const Color(0xFFA7F3D0), // Light green
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              BarChartRodData(
                toY: (data['delivered'] ?? 0).toDouble(),
                color: const Color(0xFF00C896), // Dark green
                width: 14,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStaffItem(
      {required String name,
      required String deliveries,
      required int efficiency}) {
    Color efficiencyColor =
        efficiency >= 90 ? const Color(0xFF00C896) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            backgroundImage: const NetworkImage(
                "https://i.pravatar.cc/150?img=11"), // Provide placeholder or load real image
            radius: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  deliveries,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$efficiency%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: efficiencyColor,
                ),
              ),
              const Text(
                "EFFICIENCY",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProblemRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF991B1B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF991B1B),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
