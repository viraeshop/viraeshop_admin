import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_api/apiCalls/order_lifecycle.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatefulWidget {
  static const String path = '/order_tracking';
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderLifecycleApi _api = const OrderLifecycleApi();
  late Future<List<dynamic>> _timelineFuture;

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      _timelineFuture = _api.getTimeline(
        orderId: widget.orderId!,
        token: Hive.box('adminInfo').get('token'),
      );
    } else {
      _timelineFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Track Order #${widget.orderId ?? ''}"),
        backgroundColor: kNewMainColor,
      ),
      body: widget.orderId == null
          ? const Center(child: Text("No order selected"))
          : Column(
              children: [
                // Map Placeholder (optional)
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                      child: Text("Live Tracking Map",
                          style: TextStyle(color: Colors.grey))),
                ),

                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _timelineFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }
                      final events = snapshot.data ?? [];

                      if (events.isEmpty) {
                        return const Center(child: Text("No events found."));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index]; // Map expected
                          final isLast = index == events.length - 1;
                          final date = DateTime.parse(event['timestamp']);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Time
                              SizedBox(
                                width: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(DateFormat('hh:mm a').format(date),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                    Text(DateFormat('dd MMM').format(date),
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 10)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Dot & Line
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                        color: kNewMainColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2)),
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 60, // approximate height
                                      color: Colors.grey.withOpacity(0.3),
                                    )
                                ],
                              ),
                              const SizedBox(width: 16),

                              // Content
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.withOpacity(0.1))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(event['title'] ?? 'Event',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(event['description'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
