import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_api/models/admin/admins.dart';
import 'package:viraeshop_bloc/orders/orders_bloc.dart';
import 'package:viraeshop_bloc/orders/orders_event.dart';
import 'package:viraeshop_bloc/orders/orders_state.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/admin/admin_event.dart';
import 'package:viraeshop_bloc/admin/admin_state.dart';
import 'package:viraeshop_bloc/processing/processing_bloc.dart';
import 'package:viraeshop_bloc/processing/processing_event.dart';
import 'package:viraeshop_bloc/processing/processing_state.dart';
import 'package:viraeshop_admin/features/order_management/screens/order_tracking_screen.dart';

class DeliveryManagerScreen extends StatefulWidget {
  static const String path = '/delivery_manager';
  final String token;
  const DeliveryManagerScreen({super.key, this.token = ''});

  @override
  State<DeliveryManagerScreen> createState() => _DeliveryManagerScreenState();
}

class _DeliveryManagerScreenState extends State<DeliveryManagerScreen> {
  String _selectedTab = 'Ready';
  int _expandedIndex = 0;
  String? _selectedAdminId;
  int _selectedDuration = 180; // Default 3 Hours

  final List<String> _tabs = ['Pending', 'Ready', 'In Transit', 'Delivered'];
  final List<Map<String, dynamic>> _durationOptions = [
    {'label': '1 Hour', 'value': 60},
    {'label': '2 Hours', 'value': 120},
    {'label': '3 Hours', 'value': 180},
    {'label': '4 Hours', 'value': 240},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    String apiStatus = 'Ready for Delivery';
    if (_selectedTab == 'Pending') apiStatus = 'Processing';
    if (_selectedTab == 'In Transit') apiStatus = 'Out for Delivery';
    if (_selectedTab == 'Delivered') apiStatus = 'Delivered';

    context
        .read<OrdersBloc>()
        .add(GetOrdersEvent(token: widget.token, data: {'status': apiStatus}));
    context.read<AdminBloc>().add(GetAdminsEvent(token: widget.token));
  }

  void _onTabChanged(String tab) {
    setState(() {
      _selectedTab = tab;
      _expandedIndex = 0;
      _selectedAdminId = null;
    });
    _fetchData();
  }

  void _assignTask(String orderId) {
    if (_selectedAdminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select a delivery person",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    context.read<ProcessingBloc>().add(AssignTaskEvent(
        orderId: orderId,
        adminId: _selectedAdminId!,
        taskType: 'delivery',
        durationMinutes: _selectedDuration,
        token: widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProcessingBloc, ProcessingState>(
            listener: (context, state) {
          if (state is ProcessingSuccess && !state.isSettlement) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF00C896)));
            _fetchData();
          } else if (state is ProcessingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent));
          }
        })
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              _buildTabBar(),
              Expanded(
                child: BlocBuilder<OrdersBloc, OrderState>(
                  builder: (context, state) {
                    if (state is LoadingOrderState) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF00C896)));
                    }
                    if (state is FetchedOrdersState) {
                      final orders = state.orderList;

                      if (orders.isEmpty) {
                        return Center(
                            child: Text("No $_selectedTab Orders",
                                style: const TextStyle(
                                    color: Color(0xFF64748B), fontSize: 16)));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(orders.length),
                                const SizedBox(height: 16),
                                _buildExpandedCard(orders[index]),
                              ],
                            );
                          }
                          return index == _expandedIndex
                              ? _buildExpandedCard(orders[index])
                              : _buildCollapsedCard(orders[index], index);
                        },
                      );
                    }
                    return const Center(
                        child: Text("Failed to load orders",
                            style: TextStyle(color: Colors.redAccent)));
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Color(0xFF1E293B), size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Delivery Manager",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: const Icon(Icons.notifications_none,
                    color: Color(0xFF1E293B), size: 22),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=11'), // Placeholder avatar
            backgroundColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _tabs.map((tab) {
          final isSelected = tab == _selectedTab;
          return GestureDetector(
            onTap: () => _onTabChanged(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected
                        ? const Color(0xFF00C896)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeader(int count) {
    String title = "Ready for Delivery";
    if (_selectedTab == 'Pending') title = "Pending Orders";
    if (_selectedTab == 'In Transit') title = "Out for Delivery";
    if (_selectedTab == 'Delivered') title = "Completed Deliveries";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2FBE9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$count ORDERS",
            style: const TextStyle(
              color: Color(0xFF00C896),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedCard(Orders order) {
    final imageUrl = order.items.isNotEmpty
        ? order.items.first.productImage
        : 'https://via.placeholder.com/400';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Header Image with pills
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 200, color: Colors.grey[300]),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C896),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text("READY",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.priority_high,
                              color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text("HIGH",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          // Details Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Order #${order.orderId}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderTrackingScreen(
                                  orderId: order.orderId?.toString(),
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.launch,
                              color: Color(0xFF00C896), size: 18),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2FBE9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Processing Complete",
                        style: TextStyle(
                          color: Color(0xFF00C896),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFF64748B), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.shippingAddress,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Form section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SELECT DELIVERY PERSON",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<AdminBloc, AdminState>(
                        builder: (context, state) {
                          List<AdminModel> admins = [];
                          if (state is FetchedAdminsState) {
                            admins = state.adminList ?? [];
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedAdminId,
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person,
                                          color: Color(0xFF64748B), size: 20),
                                      SizedBox(width: 12),
                                      Text("Assign Person",
                                          style: TextStyle(
                                              color: Color(0xFF1E293B),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                icon: const Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(0xFF64748B)),
                                ),
                                items: admins
                                    .map((admin) => DropdownMenuItem(
                                          value: admin.adminId,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.person,
                                                    color: Color(0xFF64748B),
                                                    size: 20),
                                                const SizedBox(width: 12),
                                                Text("${admin.name} (Active)",
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF1E293B),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedAdminId = val),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "EXPECTED DELIVERY TIME",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedDuration,
                            icon: const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(Icons.keyboard_arrow_down,
                                  color: Colors
                                      .transparent), // Hide arrow if prefer static look like input
                            ),
                            items: _durationOptions
                                .map((opt) => DropdownMenuItem<int>(
                                      value: opt['value'] as int,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time_filled,
                                                color: Color(0xFF94A3B8),
                                                size: 20),
                                            const SizedBox(width: 12),
                                            Text(opt['label'] as String,
                                                style: const TextStyle(
                                                    color: Color(0xFF1E293B),
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedDuration = val ?? 180),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _assignTask(order.orderId.toString()),
                          icon: const Icon(Icons.local_shipping, size: 22),
                          label: const Text(
                            "Start Delivery Run",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCollapsedCard(Orders order, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = index;
          _selectedAdminId = null; // reset selection on expand
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), // Light grey background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory_2,
                  color: Color(0xFF94A3B8), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Order #${order.orderId}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderTrackingScreen(
                                orderId: order.orderId?.toString(),
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.launch,
                            color: Color(0xFF64748B), size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00C896),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        currentIndex: 1, // Assume Orders tab is active
        items: const [
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.grid_view)),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.receipt_long)),
              label: "Orders"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.map_outlined)),
              label: "Fleet"),
          BottomNavigationBarItem(
              icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.settings)),
              label: "Setup"),
        ],
      ),
    );
  }
}
