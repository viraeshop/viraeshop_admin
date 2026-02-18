import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
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
  final TextEditingController _durationController =
      TextEditingController(text: "30"); // Default 30 mins
  String? _selectedAdminId;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    context.read<OrdersBloc>().add(GetOrdersEvent(
        token: widget.token,
        data: {'status': 'Confirmed'} // Orders ready for processing assignment
        ));
    context.read<AdminBloc>().add(GetAdminsEvent(token: widget.token));
  }

  void _assignTask(String orderId) {
    if (_selectedAdminId == null || _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Select processor and duration")));
      return;
    }

    final duration = int.tryParse(_durationController.text) ?? 30;

    context.read<ProcessingBloc>().add(AssignTaskEvent(
        orderId: orderId,
        adminId: _selectedAdminId!,
        taskType: 'processing',
        durationMinutes: duration,
        token: widget.token));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<ProcessingBloc, ProcessingState>(
            listener: (context, state) {
          if (state is ProcessingSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            _fetchData(); // Refresh list
          }
        })
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Processing Manager"),
          backgroundColor: kNewMainColor,
        ),
        body: Column(
          children: [
            // Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _statCard(
                        "Pending", "$_pendingCount", Colors.orange, isDark),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard("Active", "--", Colors.blue, isDark),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<OrdersBloc, OrderState>(
                builder: (context, state) {
                  if (state is LoadingOrderState) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FetchedOrdersState) {
                    final orders = state.orderList;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _pendingCount != orders.length) {
                        setState(() => _pendingCount = orders.length);
                      }
                    });

                    if (orders.isEmpty)
                      return const Center(
                          child: Text("No Pending Assignments"));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        return _buildAssignmentCard(
                            orders[index], isDark, theme);
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

  Widget _statCard(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Orders order, bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        children: [
          // Order Info
          ListTile(
            title: Text("Order #${order.orderId}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text("${order.items.length} Items • ${order.shippingAddress}"),
            trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text("Urgent",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))),
          ),

          const Divider(height: 1),

          // Assignment Form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: BlocBuilder<AdminBloc, AdminState>(
                          builder: (context, state) {
                            List<AdminModel> admins = [];
                            if (state is FetchedAdminsState) {
                              admins = state.adminList ?? [];
                            }
                            // Filter only processors if needed, assuming all admins for now

                            return DropdownButtonFormField<String>(
                              initialValue: _selectedAdminId,
                              hint: const Text("Select Processor"),
                              items: admins
                                  .map((admin) => DropdownMenuItem(
                                        value: admin.adminId.toString(),
                                        child: Text(admin.name),
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedAdminId = val),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                        )),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Mins",
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _assignTask(order.orderId.toString()),
                    icon: const Icon(Icons.timer),
                    label: const Text("Assign & Start Timer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNewMainColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
