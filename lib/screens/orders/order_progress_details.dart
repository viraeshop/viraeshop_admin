import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_api/models/orders/orders.dart' as orders_model;
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:intl/intl.dart';

class OrderProgressDetails extends StatelessWidget {
  final orders_model.Orders order;

  const OrderProgressDetails({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "ORDER JOURNEY\nSTATUS\n& PAYMENTS",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 20),
                        _buildPaymentBreakdown(),
                        const SizedBox(height: 30),
                        const Text(
                          "ORDER JOURNEY TRACKER",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildVerticalTracker(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: kNewMainColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
              _buildCloseButton(context),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "ORDERID: ${order.orderId}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${order.total}৳ by ${order.customer.name}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.close, size: 20, color: Colors.white),
            SizedBox(height: 2),
            Text(
              "Close",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    double total = order.total.toDouble();
    if (total == 0) total = 1; // Prevent division by zero
    double advance = order.advance.toDouble();
    double collected = order.codAmountCollected ?? 0.0;
    double totalPaid = advance + collected;

    int advancePct = ((advance / total) * 100).toInt();
    int collectedPct = ((collected / total) * 100).toInt();
    
    // fallback if no payment data but paid
    if (order.paymentStatus == 'Paid' && totalPaid == 0) {
       totalPaid = total;
       advancePct = 100;
       advance = total;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Payment Breakdown",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "Total: ${order.total}৳",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCircularChart(advancePct, kNewMainColor, "Advance", advance),
            _buildCircularChart(collectedPct, Colors.blue, "COD", collected),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Paid:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Paid via:",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                Text(
                  "Advance (${advance}৳)\nCOD (${collected}৳)",
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _buildCircularChart(int percentage, Color color, String label, double amount) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  "$percentage%",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          "${amount}৳\nPaid",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVerticalTracker() {
    return Column(
      children: [
        _buildStepFromDate(
          icon: Icons.shopping_bag_outlined,
          title: "Order Placed",
          dateStr: order.createdAt,
          isActive: true,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.person_add_alt_1_outlined,
          title: "Processing Assigned",
          date: order.processingAssignedAt,
          isActive: order.createdAt.isNotEmpty,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.precision_manufacturing_outlined,
          title: "Processing Started",
          date: order.processingStartedAt,
          isActive: order.processingAssignedAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.inventory_outlined,
          title: "Processing Completed",
          date: order.processingCompletedAt,
          isActive: order.processingStartedAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.local_shipping_outlined,
          title: "In Transit to Hub",
          date: order.inTransitToHubAt,
          isActive: order.processingCompletedAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.warehouse_outlined,
          title: "Received at Hub",
          date: order.hubReceivedAt,
          isActive: order.inTransitToHubAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.swap_horiz_outlined,
          title: "Moved to Delivery Hub",
          date: order.movedToDeliveryHubAt,
          isActive: order.hubReceivedAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.person_pin_outlined,
          title: "Delivery Assigned",
          date: order.deliveryAssignedAt,
          isActive: order.movedToDeliveryHubAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.directions_bike_outlined,
          title: "Delivery Started",
          date: order.deliveryStartedAt,
          isActive: order.deliveryAssignedAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.pin_drop_outlined,
          title: "Reached Customer",
          date: order.reachedCustomerAt,
          isActive: order.deliveryStartedAt != null,
          showConnector: true,
        ),
        _buildStepFromDate(
          icon: Icons.task_alt,
          title: "Delivered",
          date: order.deliveredAt,
          isActive: order.reachedCustomerAt != null,
          showConnector: false,
        ),
      ],
    );
  }

  Widget _buildStepFromDate({
    required IconData icon,
    required String title,
    DateTime? date,
    String? dateStr,
    required bool isActive,
    required bool showConnector,
  }) {
    bool isDone = date != null || (dateStr != null && dateStr.isNotEmpty);
    String leftText = "";
    String subtitle = "Pending";

    if (isDone) {
      if (date != null) {
        subtitle = DateFormat("dd MMM, hh:mm a").format(date.toLocal());
        leftText = DateFormat("MMM dd\nhh:mm a").format(date.toLocal());
      } else if (dateStr != null) {
        try {
          DateTime parsed = DateTime.parse(dateStr).toLocal();
          subtitle = DateFormat("dd MMM, hh:mm a").format(parsed);
          leftText = DateFormat("MMM dd\nhh:mm a").format(parsed);
        } catch (e) {
          subtitle = dateStr;
          leftText = "Done";
        }
      }
    } else if (isActive) {
      leftText = "Active";
      subtitle = "Currently waiting...";
    }

    return _buildStepRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      leftText: leftText,
      isDone: isDone,
      isActive: isActive && !isDone,
      showConnector: showConnector,
      connectorDone: isDone,
    );
  }

  Widget _buildStepRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String leftText,
    required bool isDone,
    required bool isActive,
    required bool showConnector,
    required bool connectorDone,
    String? alertMessage,
  }) {
    Color nodeColor = isDone ? kNewMainColor : (isActive ? Colors.amber : Colors.grey[300]!);
    Color iconColor = isDone ? kNewMainColor : (isActive ? Colors.amber : Colors.grey[400]!);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Text
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 12.0),
              child: Text(
                leftText,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isActive ? Colors.amber : (isDone ? kNewMainColor : Colors.grey),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Icon and Connector timeline
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: nodeColor, width: 2),
                  color: Colors.white,
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ] : null,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 4,
                    constraints: const BoxConstraints(minHeight: 40),
                    decoration: BoxDecoration(
                      color: connectorDone ? kNewMainColor : Colors.grey[300]!,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Right Text 
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (alertMessage != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange[800]),
                        const SizedBox(width: 2),
                        Text(
                          alertMessage,
                          style: TextStyle(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.bold),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (showConnector) const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final OrderTask? deliveryTask = order.deliveryTask;
    DateTime? expected = deliveryTask?.deadline;
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Text(
            "Expected Delivery:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            expected != null ? DateFormat("dd MMM yyyy").format(expected) : "Pending/TBD",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
