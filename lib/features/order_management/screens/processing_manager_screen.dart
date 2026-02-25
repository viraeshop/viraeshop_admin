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

class ProcessingManagerScreen extends StatefulWidget {
  static const String path = '/processing_manager';
  final String token;
  const ProcessingManagerScreen({super.key, this.token = ''});

  @override
  State<ProcessingManagerScreen> createState() =>
      _ProcessingManagerScreenState();
}

class _ProcessingManagerScreenState extends State<ProcessingManagerScreen> {
  // Store multiple controllers and selections per order instead of one global set
  final Map<String, TextEditingController> _durationControllers = {};
  final Map<String, String?> _selectedAdmins = {};

  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    for (var controller in _durationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fetchData() {
    context.read<OrdersBloc>().add(GetOrdersEvent(
        token: widget.token,
        data: {'status': 'Confirmed'} // Orders ready for processing assignment
        ));
    context.read<AdminBloc>().add(GetAdminsEvent(token: widget.token));
  }

  void _assignTask(String orderId) {
    if (_selectedAdmins[orderId] == null ||
        _durationControllers[orderId]?.text.isEmpty == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Select processor and duration",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent));
      return;
    }

    final duration = int.tryParse(_durationControllers[orderId]!.text) ?? 30;

    context.read<ProcessingBloc>().add(AssignTaskEvent(
        orderId: orderId,
        adminId: _selectedAdmins[orderId]!,
        taskType: 'processing',
        durationMinutes: duration,
        token: widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProcessingBloc, ProcessingState>(
            listener: (context, state) {
          if (state is ProcessingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Task Assigned Successfully!"),
                backgroundColor: const Color(0xFF00C896)));
            _fetchData(); // Refresh list
          }
        })
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF1E293B), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Overview",
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ]),
              child: const Icon(Icons.notifications_outlined,
                  color: Color(0xFF1E293B), size: 18),
            ),
          ],
        ),
        body: Column(
          children: [
            // Stats Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: _statCard("Pending Orders", "$_pendingCount",
                        const Color(0xFFFACC15), Icons.hourglass_top),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard("Active Tasks", "--",
                        const Color(0xFF3B82F6), Icons.engineering),
                  ),
                ],
              ),
            ),

            // Tab Filters (Mocked for visual match)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip("All Jobs", true),
                  const SizedBox(width: 8),
                  _filterChip("High Priority", false),
                  const SizedBox(width: 8),
                  _filterChip("Standard", false),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Main List
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _pendingCount != orders.length) {
                        setState(() => _pendingCount = orders.length);
                      }
                    });

                    if (orders.isEmpty) {
                      return Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 60, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 16),
                          const Text("No pending assignments",
                              style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        // Initialize local state for each order map if not present
                        final oid = order.orderId.toString();
                        if (!_durationControllers.containsKey(oid)) {
                          _durationControllers[oid] =
                              TextEditingController(text: "30");
                        }

                        return _buildAssignmentCard(order);
                      },
                    );
                  }
                  return const Center(child: Text("Load Data"));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(Orders order) {
    final oid = order.orderId.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 6))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Portion
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order #${order.orderId}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text("${order.items.length} Items • Standard Processing",
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Assignment Form Portion
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Assign To",
                    style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                BlocBuilder<AdminBloc, AdminState>(
                  builder: (context, state) {
                    List<AdminModel> admins = [];
                    if (state is FetchedAdminsState) {
                      admins = state.adminList ?? [];
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedAdmins[oid],
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Color(0xFF94A3B8)),
                          hint: const Text("Select Processor Profile",
                              style: TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 14)),
                          items: admins
                              .map((admin) => DropdownMenuItem(
                                    value: admin.adminId.toString(),
                                    child: Text(admin.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedAdmins[oid] = val);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text("Target Duration",
                    style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: _durationControllers[oid],
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixText: "Mins",
                            suffixStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => _assignTask(oid),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text("Start Assignment",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
