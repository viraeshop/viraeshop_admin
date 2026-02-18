import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/screens/smart_dashboard/widgets/paginated_product_table.dart';
import 'package:viraeshop_bloc/viraeshop_bloc.dart';

class DetailedProductReportScreen extends StatefulWidget {
  final String token;
  final String metric; // 'view', 'discount', 'rating', 'return', 'sales'

  const DetailedProductReportScreen({
    super.key,
    required this.token,
    this.metric = 'sales',
  });

  @override
  State<DetailedProductReportScreen> createState() =>
      _DetailedProductReportScreenState();
}

class _DetailedProductReportScreenState
    extends State<DetailedProductReportScreen> {
  String _currentMetric = 'sales';

  @override
  void initState() {
    super.initState();
    _currentMetric = widget.metric;
    _loadReport();
  }

  void _loadReport() {
    context.read<AnalyticsBloc>().add(
          LoadProductReport(
            token: widget.token,
            metric: _currentMetric,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(
        title: Text(
          'Detailed Product Report',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, color: const Color(0xFF111816)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111816)),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AnalyticsError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is ProductReportLoaded) {
                  return PaginatedProductTable(
                      items: state.report, metric: _currentMetric);
                }
                return const Center(
                    child: Text('Select a filter to view data'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip("Top Sales", 'sales'),
            const SizedBox(width: 8),
            _buildFilterChip("Most Viewed", 'view'),
            const SizedBox(width: 8),
            _buildFilterChip("High Discount", 'discount'),
            const SizedBox(width: 8),
            _buildFilterChip("Top Rated", 'rating'),
            const SizedBox(width: 8),
            _buildFilterChip("Returns", 'return'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentMetric == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _currentMetric = value;
          });
          _loadReport();
        }
      },
      selectedColor: const Color(0xFF0CBB8C).withOpacity(0.1),
      labelStyle: GoogleFonts.inter(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? const Color(0xFF0CBB8C) : Colors.black,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0CBB8C) : Colors.grey[300]!,
        ),
      ),
    );
  }
}
