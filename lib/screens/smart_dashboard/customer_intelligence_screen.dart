import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/detailed_customer_report_screen.dart';
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
                      'onTap': () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailedCustomerReportScreen(
                            customers: data.topCustomers,
                          ),
                        ),
                      ),
                    },
                    {
                      'title': 'Most Active Users',
                      'subtitle': 'High engagement & session count',
                      'icon': Icons.bolt,
                      'color': const Color(0xFF00C896),
                      'onTap': () => _showMostActiveUsers(context),
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
                      'onTap': () => _showTopSearchKeywords(context),
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
                      'onTap': () => _showTopPaymentMethods(context),
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

  void _showMostActiveUsers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Most Active Users",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Users with the highest session frequency this month",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            _buildActiveUserRow("Nabil Ahmed", "148 sessions", "Active 2m ago"),
            _buildActiveUserRow("Tariqul Islam", "125 sessions", "Active 15m ago"),
            _buildActiveUserRow("Sadia Rahman", "98 sessions", "Active 1h ago"),
            _buildActiveUserRow("Kamrul Hasan", "87 sessions", "Active 2h ago"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserRow(String name, String sessionCount, String activeTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF00C896).withOpacity(0.1),
            child: Text(
              name[0],
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00C896),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                activeTime,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sessionCount,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: const Color(0xFF00C896),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showTopSearchKeywords(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Top Search Keywords",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Most popular product searches across the shop",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            _buildKeywordRow("Smartphones", "2,450 searches", 0.95),
            _buildKeywordRow("Wireless Earbuds", "1,820 searches", 0.75),
            _buildKeywordRow("Running Shoes", "1,240 searches", 0.55),
            _buildKeywordRow("Laptops", "980 searches", 0.45),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywordRow(String keyword, String searchCount, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                keyword,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                searchCount,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF00C896)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C896)),
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }

  void _showTopPaymentMethods(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Top Payment Methods",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Customer preferred payment distribution",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethodRow("bKash", "65%", const Color(0xFFE2125B), 0.65),
            _buildPaymentMethodRow("Cash on Delivery", "22%", const Color(0xFF00C896), 0.22),
            _buildPaymentMethodRow("Visa/Mastercard", "8%", const Color(0xFF1A1F71), 0.08),
            _buildPaymentMethodRow("Rocket", "5%", const Color(0xFF8C3494), 0.05),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(String label, String value, Color progressColor, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                value,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: progressColor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          )
        ],
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
          final VoidCallback? onTap = item['onTap'] as VoidCallback?;
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
                trailing: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: onTap != null ? const Color(0xFF00C896) : Colors.grey[300],
                ),
                onTap: onTap,
              ),
              if (!isLast) Divider(height: 1, color: Colors.grey[50]),
            ],
          );
        }).toList(),
      ),
    );
  }
}
