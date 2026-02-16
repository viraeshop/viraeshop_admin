import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_bloc/orders/orders_bloc.dart';
import 'package:viraeshop_bloc/orders/orders_event.dart';
import 'package:viraeshop_bloc/orders/orders_state.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderAcceptanceScreen extends StatefulWidget {
  static const String path = '/order_acceptance';
  final String token;
  const OrderAcceptanceScreen({super.key, this.token = ''});

  @override
  State<OrderAcceptanceScreen> createState() => _OrderAcceptanceScreenState();
}

class _OrderAcceptanceScreenState extends State<OrderAcceptanceScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _fetchPendingOrders();
  }

  void _fetchPendingOrders() {
    // Assuming backend filters by status in 'data' map
    context.read<OrdersBloc>().add(GetOrdersEvent(
        token: widget.token,
        data: {'status': 'Pending'} // Adjust key based on backend requirement
        ));
  }

  void _confirmOrder(String orderId) {
    // Update status to 'Confirmed' so it appears in Processing Manager's queue
    context.read<OrdersBloc>().add(UpdateOrderEvent(
        orderId: orderId,
        token: widget.token,
        orderModel: {'orderStatus': 'Confirmed'}));
  }

  void _callCustomer(String phone) async {
    final url = "tel:$phone";
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Acceptance"),
        backgroundColor: kNewMainColor,
      ),
      body: BlocConsumer<OrdersBloc, OrderState>(
        listener: (context, state) {
          if (state is RequestFinishedOrderState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Order Confirmed")));
            _fetchPendingOrders(); // Refresh list
          }
          if (state is OnErrorOrderState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is LoadingOrderState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FetchedOrdersState) {
            final orders = state.orderList;
            if (orders.isEmpty) {
              return const Center(child: Text("No Pending Orders"));
            }

            return PageView.builder(
              controller: _pageController,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order, theme, isDark);
              },
            );
          }

          return const Center(child: Text("Load Pending Orders"));
        },
      ),
    );
  }

  Widget _buildOrderCard(Orders order, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a2d29) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        children: [
          // Header w/ Image
          Container(
            height: 200,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                image: order.items.isNotEmpty &&
                        order.items[0].productImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(order.items[0].productImage),
                        fit: BoxFit.cover)
                    : null),
            child: Stack(
              children: [
                if (order.items.isEmpty || order.items[0].productImage.isEmpty)
                  const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey)),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order #${order.orderId}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black)),
                        Text("Pending Approval",
                            style: TextStyle(
                                color: kNewMainColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _infoRow(
                      Icons.person, "Customer", order.customer.name, theme),
                  const SizedBox(height: 16),
                  _infoRow(Icons.shopping_bag, "Product",
                      "${order.items.length} Items", theme),
                  const SizedBox(height: 16),
                  _infoRow(
                      Icons.payments,
                      "Payment",
                      "${order.paymentMethod ?? 'COD'}\n৳ ${order.total}",
                      theme),
                  const SizedBox(height: 16),
                  _infoRow(Icons.location_on, "Delivery", order.shippingAddress,
                      theme),

                  const Spacer(),

                  // Action Buttons
                  OutlinedButton.icon(
                    onPressed: () => _callCustomer(order.customer.mobile),
                    icon: const Icon(Icons.call),
                    label: const Text("Call Customer"),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: kNewMainColor,
                        side: BorderSide(color: kNewMainColor),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _confirmOrder(order.orderId.toString()),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Confirm Order"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kNewMainColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: kNewMainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: kNewMainColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        )
      ],
    );
  }
}
