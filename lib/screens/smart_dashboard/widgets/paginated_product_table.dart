import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_api/models/analytics/analytics_models.dart';

class PaginatedProductTable extends StatelessWidget {
  final List<DetailedProductReportItem> items;
  final String metric;

  const PaginatedProductTable(
      {super.key, required this.items, required this.metric});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Rank')),
            const DataColumn(label: Text('Product Name')),
            DataColumn(label: Text(_getMetricLabel(metric))),
            const DataColumn(label: Text('Revenue')),
            const DataColumn(label: Text('Action')),
          ],
          rows: items.map((item) {
            return DataRow(cells: [
              DataCell(Text("#${item.rank}")),
              DataCell(
                Row(
                  children: [
                    if (item.image != null)
                      Container(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                              image: NetworkImage(item.image!),
                              fit: BoxFit.cover),
                        ),
                      ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        item.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  "${item.value}",
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(Text("৳${item.revenue}")),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _getMetricLabel(String metric) {
    switch (metric) {
      case 'view':
        return 'Views';
      case 'discount':
        return 'Discount';
      case 'rating':
        return 'Rating';
      case 'return':
        return 'Return Count';
      default:
        return 'Sales Volume';
    }
  }
}
