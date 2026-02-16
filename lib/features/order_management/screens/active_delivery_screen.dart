import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/features/order_management/screens/payment_collection_screen.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  static const String path = '/active_delivery';
  final Orders? order;
  final OrderTask? task;

  const ActiveDeliveryScreen({super.key, this.order, this.task});

  void _launchMaps() async {
    if (order == null) return;
    // Basic intent to launch maps with address
    final query = Uri.encodeComponent(order!.shippingAddress);
    final googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      // handle error
    }
  }

  void _callCustomer() async {
    if (order == null) return;
    final url =
        "tel:${order!.customer.mobile}"; // Assuming phone number exists on customer model
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Delivery"),
        backgroundColor: kNewMainColor,
      ),
      body: order == null
          ? const Center(child: Text("No active delivery selected"))
          : Column(
              children: [
                // Map Section (Placeholder)
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Center(
                          child: Text("Map View Placeholder",
                              style: TextStyle(color: Colors.grey))),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: _launchMaps,
                          backgroundColor: kNewMainColor,
                          child:
                              const Icon(Icons.navigation, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),

                // Details Sheet
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -5))
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Delivery to",
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(order!.customer.name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            IconButton(
                              onPressed: _callCustomer,
                              icon:
                                  const Icon(Icons.phone, color: kNewMainColor),
                              style: IconButton.styleFrom(
                                  backgroundColor:
                                      kNewMainColor.withOpacity(0.1)),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Address
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(order!.shippingAddress))
                          ],
                        ),

                        const Divider(height: 32),

                        // Order Summary
                        Text("Order #${order!.orderId}",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                            "${order!.items.length} Items • ${order!.paymentMethod ?? 'COD'}",
                            style: const TextStyle(color: Colors.grey)),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to Payment Collection Screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentCollectionScreen(
                                    order: order!,
                                    task: task!,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kNewMainColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            child: const Text("I've Reached Customer"),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
