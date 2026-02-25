import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              "ORDER TRACKING",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "#VS-${widget.orderId ?? 'Pending'}", // Adding VS- formatting from mockup
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(bottom: 140), // Space for floating bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMapHeader(),
                const SizedBox(height: 32),
                _buildTimelineHeader(),
                const SizedBox(height: 16),
                _buildTimelineList(),
                const SizedBox(height: 32),
                _buildPersonnelSection(),
              ],
            ),
          ),

          // Floating Help Bar
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _buildFloatingHelpBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Simulated Map Area
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              color: Color(0xFFE2E8F0),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.map, size: 64, color: Color(0xFFCBD5E1)),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1), blurRadius: 4)
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C896),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "LIVE TRACKING",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      _mapFloatingAction(Icons.my_location),
                      const SizedBox(height: 8),
                      _mapFloatingAction(Icons.layers),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Estimated Arrival Action
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ESTIMATED ARRIVAL",
                        style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text("Pending",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B))),
                      ],
                    )
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text("Map",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C896),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _mapFloatingAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
        ],
      ),
      child: Icon(icon, color: const Color(0xFF00C896), size: 18),
    );
  }

  Widget _buildTimelineHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Timeline Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2FBE9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "4 of 5 Steps",
              style: TextStyle(
                  color: Color(0xFF00C896),
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: FutureBuilder<List<dynamic>>(
        future: _timelineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C896)));
          }
          final events = snapshot.data ?? [];
          if (events.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text("No tracking events yet.",
                    style: TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isFirst = index == 0;
              final isLast = index == events.length - 1;
              final date = DateTime.tryParse(event['timestamp'] ?? '');
              final timeString =
                  date != null ? DateFormat('hh:mm a').format(date) : "Pending";

              return _timelineRow(
                title: event['title'] ?? 'Event',
                subtitle: event['description'] ?? '',
                time: timeString,
                icon: Icons
                    .check, // Adjust icon logic dynamically if backend maps them
                isCompleted: true,
                isFirst: isFirst,
                isLast: isLast,
              );
            },
          );
        },
      ),
    );
  }

  Widget _timelineRow({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    bool isCompleted = false,
    bool isFirst = false,
    bool isLast = false,
    bool showLine = true,
  }) {
    Color primaryColor =
        isCompleted ? const Color(0xFF00C896) : const Color(0xFFE2E8F0);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 24),
          // Connector Column
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: isCompleted ? Colors.white : const Color(0xFF94A3B8),
                    size: 16),
              ),
              if (!isLast && showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? const Color(0xFF00C896)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildPersonnelSection() {
    return const SizedBox.shrink();
  }

  Widget _buildFloatingHelpBar() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
          color: const Color(0xFF111827), // Dark navy slate
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C896).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -16,
            top: 6,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: const Color(0xFF00C896),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00C896).withOpacity(0.4),
                      blurRadius: 10,
                    )
                  ]),
              child: const Icon(Icons.local_shipping,
                  color: Colors.white, size: 24),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 56, top: 22),
            child: Row(
              children: [
                Icon(Icons.headset_mic, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  "Need Help with this Order?",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
