import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/human_resources_card.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/operations_health_card.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class OperationsManagementScreen extends StatefulWidget {
  final String token;
  const OperationsManagementScreen({super.key, required this.token});

  @override
  State<OperationsManagementScreen> createState() =>
      _OperationsManagementScreenState();
}

class _OperationsManagementScreenState
    extends State<OperationsManagementScreen> {
  int _bottomNavIndex = 2; // Default to operations looking tab
  String _selectedCategory = 'Delivery Metrics';

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
            'Operations Management',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF111816),
            ),
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
            } else if (state is OperationsHealthLoaded) {
              final data = state.data;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildFilterChips(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader("OPERATIONS HEALTH DASHBOARD"),
                          const SizedBox(height: 12),
                          OperationsHealthCard(metrics: data.health),
                          const SizedBox(height: 24),
                          _buildSectionHeader("LOGISTICS"),
                          const SizedBox(height: 12),
                          _buildNavigationCard([
                            {
                              'title': 'Delivery Man Performance',
                              'icon': Icons.local_shipping,
                              'color': Colors.blue,
                            },
                            {
                              'title': 'Top Suppliers',
                              'icon': Icons.inventory_2,
                              'color': Colors.indigo,
                            }
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionHeader("PROCESSING"),
                          const SizedBox(height: 12),
                          _buildNavigationCard([
                            {
                              'title': 'Product Processing Perf.',
                              'icon': Icons.precision_manufacturing,
                              'color': const Color(0xFF00C896),
                            },
                            {
                              'title': 'Top Sellers & Brands',
                              'icon': Icons.storefront,
                              'color': Colors.orange,
                            }
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionHeader("ORDERS"),
                          const SizedBox(height: 12),
                          _buildNavigationCard([
                            {
                              'title': 'Top Order Receiving Staff',
                              'icon': Icons.receipt_long,
                              'color': const Color(0xFF00C896),
                            }
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionHeader("HUMAN RESOURCES"),
                          const SizedBox(height: 12),
                          _buildNavigationCard([
                            {
                              'title': 'Top Employee Performance',
                              'subtitle': 'Based on monthly KPIs',
                              'icon': Icons.badge,
                              'color': Colors.purple,
                            }
                          ]),
                          const SizedBox(height: 16),
                          HumanResourcesCard(scorecard: data.employeeScorecard),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Calculating metrics...'));
          },
        ),
        );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip("Delivery Metrics", isFirst: true),
          _buildChip("Processing"),
          _buildChip("Order Receiving"),
          _buildChip("Human Resources"),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isFirst = false}) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: EdgeInsets.only(right: 8.0, left: isFirst ? 0 : 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (val) setState(() => _selectedCategory = label);
        },
        selectedColor: const Color(0xFF00C896),
        backgroundColor: Colors.white,
        labelStyle: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF111816),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey[200]!),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildNavigationCard(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData,
                      color: item['color'] as Color, size: 20),
                ),
                title: Text(
                  item['title'] as String,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF111816),
                  ),
                ),
                subtitle: item.containsKey('subtitle')
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item['subtitle'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : null,
                trailing: const Icon(Icons.chevron_right,
                    size: 20, color: Colors.grey),
                onTap: () {},
              ),
              if (!isLast) Divider(height: 1, color: Colors.grey[50]),
            ],
          );
        }).toList(),
      ),
    );
  }
}
