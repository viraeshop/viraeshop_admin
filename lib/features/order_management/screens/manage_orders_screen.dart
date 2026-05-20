import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_bloc/orders/orders_bloc.dart';
import 'package:viraeshop_bloc/orders/orders_event.dart';
import 'package:viraeshop_bloc/orders/orders_state.dart';
import 'dart:async';

class ManageOrdersScreen extends StatefulWidget {
  static const String path = '/manage_orders';
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final String token = Hive.box('adminInfo').get('token') ?? '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _fetchOrders();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchOrders();
    });
  }

  void _fetchOrders() {
    String status = 'Pending';
    if (_tabController.index == 1) status = 'Completed';
    if (_tabController.index == 2) status = 'Canceled';

    context.read<OrdersBloc>().add(GetOrdersEvent(
          token: token,
          data: {
            'filterType': 'manageOrders',
            'filterData': {
              'status': status,
              'searchQuery': _searchController.text.trim(),
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Orders",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications_none, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search by Order ID or Customer",
                  hintStyle:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Custom Tab Pills
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabPill("Pending", 0),
                const SizedBox(width: 12),
                _buildTabPill("Completed", 1),
                const SizedBox(width: 12),
                _buildTabPill("Canceled", 2),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<OrdersBloc, OrderState>(
              builder: (context, state) {
                if (state is LoadingOrderState) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF00C896)));
                }
                if (state is FetchedOrdersState) {
                  final orders = state.orderList;
                  if (orders.isEmpty) {
                    return const Center(
                      child: Text(
                        "No more pending orders",
                        style:
                            TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(order: orders[index]);
                    },
                  );
                }
                if (state is OnErrorOrderState) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    bool isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabController.animateTo(index)),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00C896) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00C896)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Orders order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String timeAgo = _getTimeAgo(order.createdAt);
    final bool isUrgent = order.items.length > 3; // Example logic for urgency
    final bool isNew = order.orderStatus.toLowerCase() == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: Color(0xFF94A3B8), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order #${order.orderId}",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                            if (isNew) ...[
                              const SizedBox(width: 8),
                              _statusBadge("New", const Color(0xFFE2FBE9),
                                  const Color(0xFF00C896)),
                            ],
                            if (isUrgent) ...[
                              const SizedBox(width: 8),
                              _statusBadge(
                                  "Urgent",
                                  const Color(0xFFFEF2F2),
                                  const Color(
                                      0xFFF97316)), // Design shows orange/red for urgent
                            ]
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.customer.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${order.items.length} Items • ${order.paymentMethod ?? 'COD'}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1.2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Amount",
                    style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "৳ ${NumberFormat('#,##0.00').format(order.grandTotal)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00C896),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // All cards now navigate to Order Acceptance Screen as requested
                    String status = 'Pending';
                    if (order.orderStatus.toLowerCase() == 'success' ||
                        order.orderStatus.toLowerCase() == 'completed')
                      status = 'Completed';
                    if (order.orderStatus.toLowerCase() == 'canceled' ||
                        order.orderStatus.toLowerCase() == 'failed')
                      status = 'Canceled';

                    Navigator.pushNamed(context, '/order_acceptance',
                        arguments: {
                          'orderId': order.orderId,
                          'status': status
                        });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF1E293B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                  child: const Text("View Details",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _getTimeAgo(String createdAt) {
    try {
      final DateTime date = DateTime.parse(createdAt);
      final Duration diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return "${diff.inDays}d ago";
      if (diff.inHours > 0) return "${diff.inHours}h ago";
      if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
      return "Just now";
    } catch (e) {
      return "";
    }
  }
}
