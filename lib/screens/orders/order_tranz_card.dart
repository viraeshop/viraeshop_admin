import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_api/models/orders/orders.dart' as orders_model;
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:viraeshop_admin/reusable_widgets/orders/delivery_timer.dart';
import 'package:intl/intl.dart';
import 'package:viraeshop_admin/screens/orders/order_progress_details.dart';

class OrderTranzCard extends StatefulWidget {
  final String price, employeeName, date, desc, customerName;
  final String? id;
  final String processingStatus;
  final IconData? status;
  final Color? statusColor;
  final bool isTransaction;
  final bool isAdmin;
  final Function()? onTap;
  final orders_model.Orders? order;

  const OrderTranzCard({
    required this.price,
    required this.employeeName,
    required this.desc,
    required this.date,
    required this.customerName,
    required this.onTap,
    this.isTransaction = true,
    this.isAdmin = false,
    this.processingStatus = '',
    this.id,
    this.status,
    this.statusColor,
    this.order,
    Key? key,
  }) : super(key: key);

  @override
  State<OrderTranzCard> createState() => _OrderTranzCardState();
}

class _OrderTranzCardState extends State<OrderTranzCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigable Area
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopRow(),
                  const SizedBox(height: 12),
                  _buildSummaryRow(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Interaction Bar (Order ID and Expand Toggle)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCustomerInfoPart(),
                _buildActionPart(),
              ],
            ),
          ),

          if (_isExpanded && widget.order != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Divider(height: 32),
                  _buildTrackingStepper(),
                  const SizedBox(height: 24),
                  _buildPossessionHeader(),
                  const SizedBox(height: 12),
                  _buildEmployeeSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerInfoPart() {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          children: [
            const Icon(Icons.person, color: kSubMainColor, size: 24),
            const SizedBox(width: 8),
            Text(
              widget.customerName,
              style: const TextStyle(
                color: kSubMainColor,
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPart() {
    return Row(
      children: [
        const Icon(Icons.show_chart, color: Colors.red, size: 18),
        const SizedBox(width: 4),
        Text(
          'OrderID: ${widget.id}',
          style: kTableCellStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.red,
          ),
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
      ],
    );
  }


  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.payments, size: 30.0, color: kSubMainColor),
            const SizedBox(width: 12),
            Text(
              '${widget.order?.grandTotal ?? widget.price}৳',
              style: const TextStyle(
                color: kSubMainColor,
                fontSize: 18.0,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'by ${widget.employeeName}',
              style: TextStyle(
                color: kProductCardColor.withOpacity(0.7),
                fontSize: 12.0,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.processingStatus.isEmpty ? 'Pending' : widget.processingStatus,
              style: TextStyle(
                color: _getStatusColor(widget.processingStatus),
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            Text(widget.date, style: kProductNameStylePro.copyWith(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Text(
      widget.desc,
      style: kProductNameStylePro.copyWith(color: kProductCardColor, fontSize: 13),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }


  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status == 'new' || status == 'pending') return kYellowColor;
    if (status == 'assigned') return const Color(0xFF3B82F6); // Blue
    if (status == 'processing') return const Color(0xFFF59E0B); // Amber
    if (status == 'confirmed' || status == 'success' || status == 'delivered' || status == 'out for delivery' || status == 'received') return kNewMainColor;
    if (status == 'failed' || status == 'cancelled') return kRedColor;
    return kBrownColorAccent;
  }  
  Widget _buildTrackingStepper() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => OrderProgressDetails(order: widget.order!),
        );
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildAllHorizontalSteps(),
        ),
      ),
    );
  }

  List<Widget> _buildAllHorizontalSteps() {
    List<Widget> children = [];
    
    void addStep(IconData icon, String title, DateTime? date, String? dateStr, bool isActive, bool isLast) {
      bool isDone = date != null || (dateStr != null && dateStr.isNotEmpty);
      String? timeLabel;
      if (isDone) {
        if (date != null) {
          timeLabel = DateFormat("MMM dd, hh:mm a").format(date.toLocal());
        } else if (dateStr != null) {
          try {
            timeLabel = DateFormat("MMM dd, hh:mm a").format(DateTime.parse(dateStr).toLocal());
          } catch (e) {
            timeLabel = "Done";
          }
        }
      }

      children.add(
        _buildStepIndicator(
          icon: icon,
          label: title,
          isDone: isDone,
          isActive: isActive && !isDone,
          timeLabel: timeLabel,
          activeLabel: isActive && !isDone ? "Active" : null,
        )
      );

      if (!isLast) {
        children.add(_buildConnector(isDone: isDone));
      }
    }

    addStep(Icons.shopping_bag_outlined, "Order Placed", null, widget.order!.createdAt, true, false);
    addStep(Icons.person_add_alt_1_outlined, "Processing Assigned", widget.order!.processingAssignedAt, null, widget.order!.createdAt.isNotEmpty, false);
    addStep(Icons.precision_manufacturing_outlined, "Processing Started", widget.order!.processingStartedAt, null, widget.order!.processingAssignedAt != null, false);
    addStep(Icons.inventory_outlined, "Processing Completed", widget.order!.processingCompletedAt, null, widget.order!.processingStartedAt != null, false);
    addStep(Icons.local_shipping_outlined, "In Transit to Hub", widget.order!.inTransitToHubAt, null, widget.order!.processingCompletedAt != null, false);
    addStep(Icons.warehouse_outlined, "Received at Hub", widget.order!.hubReceivedAt, null, widget.order!.inTransitToHubAt != null, false);
    addStep(Icons.swap_horiz_outlined, "Moved to Delivery Hub", widget.order!.movedToDeliveryHubAt, null, widget.order!.hubReceivedAt != null, false);
    addStep(Icons.person_pin_outlined, "Delivery Assigned", widget.order!.deliveryAssignedAt, null, widget.order!.movedToDeliveryHubAt != null, false);
    addStep(Icons.directions_bike_outlined, "Delivery Started", widget.order!.deliveryStartedAt, null, widget.order!.deliveryAssignedAt != null, false);
    addStep(Icons.pin_drop_outlined, "Reached Customer", widget.order!.reachedCustomerAt, null, widget.order!.deliveryStartedAt != null, false);
    addStep(Icons.task_alt, "Delivered", widget.order!.deliveredAt, null, widget.order!.reachedCustomerAt != null, true);

    return children;
  }

  Widget _buildStepIndicator({
    required IconData icon,
    required String label,
    bool isDone = false,
    bool isActive = false,
    String? timeLabel,
    String? activeLabel,
  }) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone ? kNewMainColor : (isActive ? Colors.amber : kProductCardColor.withOpacity(0.3)),
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDone ? kNewMainColor : (isActive ? Colors.amber : kProductCardColor.withOpacity(0.5)),
                ),
              ),
              if (isDone)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: kNewMainColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.amber : (isDone ? Colors.black87 : kProductCardColor),
              fontFamily: 'Montserrat',
            ),
          ),
          if (timeLabel != null)
            Text(
              timeLabel,
              style: const TextStyle(fontSize: 8, color: kNewMainColor, fontWeight: FontWeight.bold),
            ),
          if (activeLabel != null && isActive)
            Text(
              activeLabel,
              style: const TextStyle(fontSize: 8, color: Colors.amber, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildConnector({bool isDone = false}) {
    return Container(
      width: 20,
      height: 4,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDone ? kNewMainColor : kProductCardColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildPossessionHeader() {
    return Text(
      "LAST EMPLOYEE IN POSSESSION:",
      style: TextStyle(
        color: kProductCardColor.withOpacity(0.8),
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildEmployeeSection() {
    final deliveryTask = widget.order!.deliveryTask;
    final processingTask = widget.order!.processorsTasks.firstWhere(
        (t) => t.taskType == 'processing' && (t.taskStatus == 'active' || t.taskStatus == 'pending'),
        orElse: () => OrderTask());
    
    final activeTask = (deliveryTask != null && (deliveryTask.taskStatus == 'active' || deliveryTask.taskStatus == 'pending')) 
        ? deliveryTask 
        : (processingTask.taskStatus != null ? processingTask : null);

    return Column(
      children: [
        if (activeTask != null) ...[
          DeliveryTimer(task: activeTask, compact: true),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
             CircleAvatar(
              radius: 20,
              backgroundColor: kSubMainColor.withOpacity(0.1),
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=${widget.employeeName}&background=0CBB8B&color=fff'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.employeeName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Montserrat'),
                  ),
                  Text(
                    activeTask?.taskType == 'delivery' ? "Order Dispatcher" : "Order Packer",
                    style: TextStyle(color: kProductCardColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (activeTask?.deadline != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Expected Time:",
                    style: TextStyle(color: kProductCardColor, fontSize: 10),
                  ),
                  Text(
                    DateFormat.Hm().format(activeTask!.deadline!),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Montserrat'),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
