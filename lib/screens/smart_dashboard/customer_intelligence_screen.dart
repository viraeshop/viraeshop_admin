import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/tier_system_widget.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class CustomerIntelligenceScreen extends StatefulWidget {
  final String token;
  const CustomerIntelligenceScreen({super.key, required this.token});

  @override
  State<CustomerIntelligenceScreen> createState() =>
      _CustomerIntelligenceScreenState();
}

class _CustomerIntelligenceScreenState
    extends State<CustomerIntelligenceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(LoadCustomerIntelligence(widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Customer Intelligence',
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
          } else if (state is CustomerIntelligenceLoaded) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryPills(data),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Tier System", isActive: true),
                  const SizedBox(height: 12),
                  TierSystemWidget(tiers: data.tiers),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Customer Reports"),
                  const SizedBox(height: 12),
                  _buildNavigationCard([
                    {
                      'title': 'Top Customers (VIP)',
                      'subtitle': 'Rank 1 - 100 based on spend',
                      'icon': Icons.stars,
                      'color': const Color(0xFF00C896),
                    },
                    {
                      'title': 'Most Active Users',
                      'subtitle': 'High engagement & session count',
                      'icon': Icons.bolt,
                      'color': const Color(0xFF00C896),
                    }
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader("User Behavior"),
                  const SizedBox(height: 12),
                  _buildNavigationCard([
                    {
                      'title': 'Top Search Keywords',
                      'subtitle': 'Rank 1 - 50 by volume',
                      'icon': Icons.search,
                      'color': const Color(0xFF00C896),
                    }
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Customer Preferences"),
                  const SizedBox(height: 12),
                  _buildNavigationCard([
                    {
                      'title': 'Top Payment Methods',
                      'subtitle': 'Rank 1 - 10 Preferred ways to pay',
                      'icon': Icons.payments_outlined,
                      'color': const Color(0xFF00C896),
                    }
                  ]),
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

  Widget _buildSectionHeader(String title, {bool isActive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111816),
          ),
        ),
        if (isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Active",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00C896),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildSummaryPills(CustomerIntelligenceModel data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPill("Total Purchase", data.totalPurchase ?? "-",
              const Color(0xFF00C896)),
          _buildPill(
              "Frequency", data.frequency ?? "-", const Color(0xFF00C896)),
          _buildPill(
              "Avg Rating", data.avgRating ?? "-", const Color(0xFF00C896)),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
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
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    item['subtitle'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
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
