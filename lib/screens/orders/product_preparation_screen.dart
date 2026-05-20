import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/boxes.dart';
import 'package:viraeshop_api/models/items/items.dart';
import 'package:viraeshop_api/utils/utils.dart';
import 'package:viraeshop_bloc/items/barrel.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';

class ProductPreparationScreen extends StatefulWidget {
  final String orderId;
  const ProductPreparationScreen({Key? key, required this.orderId})
      : super(key: key);

  @override
  _ProductPreparationScreenState createState() =>
      _ProductPreparationScreenState();
}

class _ProductPreparationScreenState extends State<ProductPreparationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String jWTToken = Hive.box('adminInfo').get('token');
  List<dynamic> _groupedItems = [];
  List<dynamic> _filteredGroupedItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchData() {
    context.read<OrderItemsBloc>().add(
          GetPreparationItemsEvent(orderId: widget.orderId, token: jWTToken),
        );
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGroupedItems = _groupedItems;
      } else {
        _filteredGroupedItems = _groupedItems
            .map((group) {
              final items = (group['items'] as List).where((item) {
                final productName =
                    (item is Items ? item.productName : item['productName'])
                        .toString()
                        .toLowerCase();
                return productName.contains(query);
              }).toList();

              if (items.isNotEmpty ||
                  group['supplierName']
                      .toString()
                      .toLowerCase()
                      .contains(query)) {
                return {
                  ...group,
                  'items': items.isEmpty ? group['items'] : items,
                };
              }
              return null;
            })
            .where((group) => group != null)
            .toList();
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    for (var group in _groupedItems) {
      for (var itemData in group['items']) {
        final item = itemData is Items ? itemData : Items.fromJson(itemData);
        if (item.processingStatus == 'confirmed' &&
            (item.availability ?? true)) {
          total += item.unitPrice * item.quantity;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderItemsBloc, OrderItemState>(
      listener: (context, state) {
        if (state is FetchedPreparationItemsState) {
          setState(() {
            _groupedItems = state.groupedItems;
            _filteredGroupedItems = state.groupedItems;
            _isLoading = false;
          });
        } else if (state is OnErrorOrderItemState) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        } else if (state is RequestFinishedOrderItemState) {
          _fetchData(); // Refresh data after update
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5F2), // Light cream background
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5E3C), Color(0xFFD9A066)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Admin Order",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Search items or suppliers...",
                          hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF8B5E3C)),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5E3C)))
            : _errorMessage != null
                ? Center(
                    child: Text(_errorMessage!, style: GoogleFonts.inter()))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredGroupedItems.length,
                    itemBuilder: (context, index) {
                      final group = _filteredGroupedItems[index];
                      return _buildSupplierCard(group);
                    },
                  ),
        bottomNavigationBar: _buildBottomLogisticsBar(),
      ),
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic> group) {
    final items = group['items'] as List;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5E3C).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      size: 20, color: Color(0xFF8B5E3C)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${group['supplierName']} (Unified)",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: const Color(0xFF5D4037),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF8B5E3C).withOpacity(0.2)),
                  ),
                  child: Text(
                    "${items.length} Items",
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B5E3C)),
                  ),
                ),
              ],
            ),
          ),
          ...items.map((itemData) {
            final item =
                itemData is Items ? itemData : Items.fromJson(itemData);
            return _buildProductItem(item);
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProductItem(Items item) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.productImage,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF1E293B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "${item.unitPrice.toStringAsFixed(0)}$bdtSign",
                      style: GoogleFonts.outfit(
                          color: const Color(0xFF8B5E3C),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "× ${item.quantity}",
                      style: GoogleFonts.inter(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusDropdown(item),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${(item.unitPrice * item.quantity).toStringAsFixed(0)}$bdtSign",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(Items item) {
    final currentStatus = item.processingStatus == 'confirmed'
        ? 'Confirm'
        : (item.availability == false ? 'Fail' : 'Select');
    final statusColor = currentStatus == 'Confirm'
        ? const Color(0xFF10B981)
        : (currentStatus == 'Fail'
            ? const Color(0xFFEF4444)
            : Colors.grey[600]);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: statusColor),
          style: GoogleFonts.inter(
              fontSize: 12, color: statusColor, fontWeight: FontWeight.bold),
          items: ['Select', 'Confirm', 'Fail'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) => _updateItemStatus(item, val!),
        ),
      ),
    );
  }

  void _updateItemStatus(Items item, String status) {
    Map<String, dynamic> itemInfo = {};
    if (status == 'Confirm') {
      itemInfo = {'processingStatus': 'confirmed', 'availability': true};
    } else if (status == 'Fail') {
      itemInfo = {'processingStatus': 'failed', 'availability': false};
    } else {
      itemInfo = {'processingStatus': 'pending', 'availability': true};
    }

    context.read<OrderItemsBloc>().add(
          UpdateOrderItemEvent(
            token: jWTToken,
            orderModel: {
              'id': [item.id],
              'itemInfo': itemInfo,
            },
          ),
        );
  }

  Widget _buildBottomLogisticsBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLogisticsIcon(FontAwesomeIcons.motorcycle, "Bike"),
                _buildLogisticsIcon(FontAwesomeIcons.car, "Car"),
                Column(
                  children: [
                    _buildLogisticsIcon(FontAwesomeIcons.truck, "Vira Van",
                        active: true),
                    const SizedBox(height: 6),
                    Text(
                      "Send to Delivery Hub",
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B5E3C)),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    final allIds = _groupedItems
                        .expand((g) => g['items'] as List)
                        .map((i) => (i is Items ? i.id : i['id']))
                        .toList();
                    _showHubTransitDialog(context, allIds);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(FontAwesomeIcons.paperPlane,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Preparation",
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Confirmed Items",
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B)),
                    ),
                  ],
                ),
                Text(
                  "${_calculateTotal().toStringAsFixed(0)}$bdtSign",
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5E3C)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogisticsIcon(IconData icon, String label,
      {bool active = false}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF8B5E3C).withOpacity(0.1)
                : Colors.grey[50]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: active
                ? Border.all(
                    color: const Color(0xFF8B5E3C).withOpacity(0.3), width: 1.5)
                : Border.all(color: Colors.grey[200]!),
          ),
          child: Icon(icon,
              color: active ? const Color(0xFF8B5E3C) : Colors.grey[400],
              size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 11,
              color: active ? const Color(0xFF1E293B) : Colors.grey[400],
              fontWeight: active ? FontWeight.w600 : FontWeight.w500),
        ),
      ],
    );
  }

  void _showHubTransitDialog(BuildContext context, List<dynamic> ids) {
    int duration = 60;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Final Batch Complete",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This is the final product batch. Please set the estimated time to reach the Receive/Delivery Hub.",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: TextFormField(
                  initialValue: "60",
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      suffixText: "min",
                      suffixStyle:
                          TextStyle(color: Colors.white70, fontSize: 16)),
                  onChanged: (val) {
                    duration = int.tryParse(val) ?? 60;
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel",
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrderItemsBloc>().add(
                    UpdateOrderItemEvent(
                      token: jWTToken,
                      orderModel: {
                        'id': ids,
                        'itemInfo': {
                          'processingStatus': 'confirmed',
                          'hubDurationMinutes': duration,
                        },
                      },
                    ),
                  );
            },
            child: const Text("Confirm & Submit",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
