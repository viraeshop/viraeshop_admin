import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/clv_cards.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/customer_report_list.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/tier_system_widget.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class CustomerIntelligenceTab extends StatelessWidget {
  final String token;
  const CustomerIntelligenceTab({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnalyticsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is CustomerIntelligenceLoaded) {
          final data = state.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                // ClvCards is implied from headers in HTML, but logic might be separate
                // Let's implement a header summary card instead if CLV specific data missing?
                // Actually CustomerIntelligenceModel has tiers and topCustomers.
                // We'll use TierSystem as primary visual.
                const Text(
                  "CUSTOMER TIERS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                TierSystemWidget(tiers: data.tiers),
                const SizedBox(height: 24),
                const Text(
                  "CUSTOMER REPORTS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                const CustomerReportList(),
                const SizedBox(height: 24),
                _buildVipList(data.topCustomers),
              ],
            ),
          );
        }
        return const Center(child: Text('Please wait...'));
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Intelligence',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111816),
              ),
            ),
            Text(
              'Track loyalty and shopping behavior',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVipList(List<dynamic> customers) {
    // Using dynamic for VipCustomer until model import is perfect
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TOP 5 VIP CUSTOMERS",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: customers.map((c) => _buildVipItem(c)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVipItem(dynamic customer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                customer.profileImage ?? "https://via.placeholder.com/40"),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  customer.mobile,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            "৳${customer.wallet ?? '0'}", // Assuming wallet is spend
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0CBB8C),
            ),
          ),
        ],
      ),
    );
  }
}
