import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/tabs/business_overview_tab.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/tabs/customer_intelligence_tab.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/tabs/operations_management_tab.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/tabs/product_intelligence_hub.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class SmartDashboardScreen extends StatefulWidget {
  static const String path = '/smart_dashboard';
  final String token;

  const SmartDashboardScreen({super.key, required this.token});

  @override
  State<SmartDashboardScreen> createState() => _SmartDashboardScreenState();
}

class _SmartDashboardScreenState extends State<SmartDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Initial Load
    context.read<AnalyticsBloc>().add(LoadBusinessHealth(widget.token));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7), // background-light
      appBar: AppBar(
        title: Text(
          'Smart Dashboard',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111816),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111816)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0CBB8C), // Primary
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0CBB8C),
          isScrollable: true,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Products"),
            Tab(text: "Customers"),
            Tab(text: "Operations"),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                context
                    .read<AnalyticsBloc>()
                    .add(LoadBusinessHealth(widget.token));
                break;
              case 1:
                context
                    .read<AnalyticsBloc>()
                    .add(LoadProductIntelligence(widget.token));
                break;
              case 2:
                context
                    .read<AnalyticsBloc>()
                    .add(LoadCustomerIntelligence(widget.token));
                break;
              case 3:
                context
                    .read<AnalyticsBloc>()
                    .add(LoadOperationsHealth(widget.token));
                break;
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BusinessOverviewTab(token: widget.token),
          ProductIntelligenceHub(token: widget.token),
          CustomerIntelligenceTab(token: widget.token),
          OperationsManagementTab(token: widget.token),
        ],
      ),
    );
  }
}
