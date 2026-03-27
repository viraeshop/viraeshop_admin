import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/features/order_management/screens/payment_collection_screen.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/delivery_timer.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  static const String path = '/active_delivery';
  final Orders? order;
  final OrderTask? task;

  const ActiveDeliveryScreen({super.key, this.order, this.task});

  void _launchMaps() async {
    if (order == null) return;
    final query = Uri.encodeComponent(order!.shippingAddress);
    final googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    }
  }

  void _callCustomer() async {
    if (order == null) return;
    final url = "tel:${order!.customer.mobile}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Active Delivery")),
        body: const Center(child: Text("No active delivery selected")),
      );
    }

    final pendingAmount = (order!.due != 0.0)
        ? order!.due.toDouble()
        : (order!.codAmountToCollect ?? order!.subTotal.toDouble());
    final displayAmount = pendingAmount < 0 ? 0.0 : pendingAmount;
    final bool isCOD =
        order!.paymentMethod?.toLowerCase() == 'cash' || pendingAmount > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Active Delivery",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(right: 16.0, top: 12.0, bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00C896),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "IN TRANSIT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 20, right: 20, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Current Trip Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFE2FBE9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CURRENT TRIP",
                            style: TextStyle(
                              color: Color(0xFF00C896),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Delivery #${order!.orderId}",
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2FBE9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.inventory_2,
                            color: Color(0xFF00C896)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
 
                // Timer Card
                (() {
                  final activeTask = task ?? order!.deliveryTask;
                  if (activeTask != null && (activeTask.taskStatus == 'active' || activeTask.taskStatus == 'pending')) {
                    return Center(child: DeliveryTimer(task: activeTask));
                  }
                  return const SizedBox.shrink();
                })(),
                const SizedBox(height: 16),
 
                // 2. Collection Alert (Only if pending amount > 0 or COD)
                if (isCOD)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF8), // Very light mint green
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF00C896), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${displayAmount.toStringAsFixed(0)} BDT",
                          style: const TextStyle(
                            color: Color(0xFF00C896),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "TO COLLECT",
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Cash on delivery payment required",
                          style: TextStyle(
                            color: Color(0xFF64748B), // Slate 500
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.payments_outlined,
                                color: Color(0xFF00C896), size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              "COD",
                              style: TextStyle(
                                color: Color(0xFF00C896),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                if (isCOD) const SizedBox(height: 16),

                // 3. Customer Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: (order!.customer.profileImage !=
                                        null &&
                                    order!.customer.profileImage!.isNotEmpty)
                                ? NetworkImage(order!.customer.profileImage!)
                                : const NetworkImage(
                                    "https://i.pravatar.cc/150?img=11"), // Placeholder fallback
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order!.customer.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Customer • Dhaka, Bangladesh", // Assuming country context
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF00C896),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _callCustomer,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00C896),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.call,
                                  color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(
                            color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2.0),
                            child: Icon(Icons.location_on,
                                color: Color(0xFF00C896), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              order!.shippingAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                                height: 1.4,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Map Interface Placeholder Segment
                GestureDetector(
                  onTap: _launchMaps,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                      image: const DecorationImage(
                        // Mock static map image for placeholder visual
                        // In production, this would be a GoogleMap widget OR we retain
                        // this placeholder approach opening the native maps app directly
                        image: NetworkImage(
                            "https://maps.googleapis.com/maps/api/staticmap?center=Dhaka,Bangladesh&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:H%7C23.8103,90.4125&key=YOUR_API_KEY_HERE"),
                        fit: BoxFit.cover,
                      ),
                      color: const Color(0xFFE2FBE9), // Fallback map color
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // Pseudo Map Layers Background pattern (if image fails)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.3,
                            child: Image.network(
                                "https://www.transparenttextures.com/patterns/cubes.png",
                                repeat: ImageRepeat.repeat),
                          ),
                        ),
                        // Top Right Control Buttons
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2))
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.my_location,
                                      color: Colors.black87, size: 20),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2))
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.layers,
                                      color: Colors.black87, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom ETA Pill
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: const Color(0xFF00C896), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Route Directions",
                                    style: TextStyle(
                                        color: Color(0xFF00C896),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.circle,
                                        size: 4, color: Color(0xFFCBD5E1)),
                                  ),
                                  const Text(
                                    "Tap Map",
                                    style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Order Summary
                const Text(
                  "ORDER SUMMARY",
                  style: TextStyle(
                    color: Color(0xFF94A3B8), // slate 400
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order!.items.length,
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(
                          color: Color(0xFFF1F5F9), height: 1, thickness: 1),
                    ),
                    itemBuilder: (context, index) {
                      final item = order!.items[index];
                      return Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFFFF7ED), // Subtle orange tint fallback
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(item.productImage),
                                fit: BoxFit.cover,
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
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Quantity: ${item.quantity}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00C896),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 6. Fixed Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // 1. Persist "reached" state so app can re-route on relaunch
                        final token = Hive.box('adminInfo').get('token');
                        context.read<OrdersBloc>().add(
                          UpdateOrderEvent(
                            orderId: order!.orderId!,
                            orderModel: {
                              'orderStage': 'delivery',
                              'notificationType': 'admin2Customer',
                              'reachedCustomer': true,
                            },
                            token: token,
                          ),
                        );
                        // 2. Navigate to payment collection
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentCollectionScreen(
                              order: order!,
                              task: task,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C896),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Reached Customer",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
