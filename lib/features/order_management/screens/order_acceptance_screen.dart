import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_bloc/orders/orders_bloc.dart';
import 'package:viraeshop_bloc/orders/orders_event.dart';
import 'package:viraeshop_bloc/orders/orders_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class OrderAcceptanceScreen extends StatefulWidget {
  static const String path = '/order_acceptance';
  final String? token;
  const OrderAcceptanceScreen({super.key, this.token});

  @override
  State<OrderAcceptanceScreen> createState() => _OrderAcceptanceScreenState();
}

class _OrderAcceptanceScreenState extends State<OrderAcceptanceScreen> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  String? _token;
  int? _initialOrderId;
  String _status = 'Pending';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _token = widget.token ?? Hive.box('adminInfo').get('token') ?? '';
    // Fetching will move to didChangeDependencies to handle arguments correctly
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        if (args.containsKey('orderId')) {
          _initialOrderId = args['orderId'];
        }
        if (args.containsKey('status')) {
          _status = args['status'];
        }
      }
      _fetchOrders(); // Fetch after setting status
      _isInitialized = true;
    }
  }

  void _fetchOrders() {
    context
        .read<OrdersBloc>()
        .add(GetOrdersEvent(token: _token ?? '', data: {'status': _status}));
  }

  void _confirmOrder(String orderId) {
    context.read<OrdersBloc>().add(UpdateOrderEvent(
        orderId: orderId,
        token: _token ?? '',
        orderModel: const {'orderStatus': 'Confirmed'}));
  }

  void _callSupplier(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        title: const Text(
          "Order Acceptance",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF1E293B)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<OrdersBloc, OrderState>(
        listener: (context, state) {
          if (state is RequestFinishedOrderState) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Order Confirmed Successfully!"),
              backgroundColor: Color(0xFF00C896),
            ));
            _fetchOrders(); // Refresh list
          }
          if (state is OnErrorOrderState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ));
          }
        },
        builder: (context, state) {
          if (state is LoadingOrderState) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C896)));
          }

          if (state is FetchedOrdersState) {
            final orders = state.orderList;
            if (orders.isEmpty) {
              return Center(
                  child: Text("No $_status Orders To Accept",
                      style: const TextStyle(color: Color(0xFF64748B))));
            }

            // Handle jumping to initial order if provided
            if (_initialOrderId != null) {
              final index =
                  orders.indexWhere((o) => o.orderId == _initialOrderId);
              if (index != -1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(index);
                  }
                  _initialOrderId = null; // Only jump once
                });
              }
            }

            return PageView.builder(
              controller: _pageController,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            );
          }

          return Center(
              child: Text("Load $_status Orders",
                  style: const TextStyle(color: Color(0xFF64748B))));
        },
      ),
    );
  }

  Widget _buildOrderCard(Orders order) {
    final hasImage =
        order.items.isNotEmpty && order.items.first.productImage.isNotEmpty;
    final imageUrl = hasImage ? order.items.first.productImage : '';
    final productName =
        order.items.isNotEmpty ? order.items.first.productName : 'Product Name';

    // Formatting Payment Method
    String paymentString = order.paymentMethod ?? 'COD';
    if (paymentString.toLowerCase() == 'cash' ||
        paymentString.toLowerCase() == 'cod') {
      paymentString = "COD (Cash on Delivery)";
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header tags
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _status.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF00C896),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2FBE9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "New Order",
                        style: TextStyle(
                          color: Color(0xFF00C896),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Order #${order.orderId}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 20),

                // Hero Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: hasImage
                      ? Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 40),
                          ),
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 64),
                        ),
                ),

                const SizedBox(height: 32),

                // Info List
                _infoRow(
                  icon: Icons.person,
                  title: "Customer",
                  content: order.customer.name,
                ),
                const SizedBox(height: 24),
                _infoRow(
                  icon: Icons.shopping_bag,
                  title: "Product",
                  content: productName,
                ),
                const SizedBox(height: 24),

                // Payment Method (with dynamic right side amount)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2FBE9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.payments,
                          color: Color(0xFF00C896), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Payment Method",
                              style: TextStyle(
                                  color: Color(0xFF64748B), fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(paymentString,
                              style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            "৳ ${NumberFormat('#,##0.00').format(order.total)}",
                            style: const TextStyle(
                                color: Color(0xFF00C896),
                                fontWeight: FontWeight.w800,
                                fontSize: 20)),
                        const Text("BDT",
                            style: TextStyle(
                                color: Color(0xFF00C896),
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 24),
                _infoRow(
                  icon: Icons.location_on,
                  title: "Delivery Address",
                  content: order.shippingAddress,
                  subtitle:
                      "Dhaka City, Bangladesh", // Mocking secondary line for visual density like the design
                ),

                const SizedBox(height: 40),

                // Call Supplier outline button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _callSupplier(order.customer.mobile),
                    icon: const Icon(Icons.call, size: 20),
                    label: const Text(
                      "Call Supplier",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00C896),
                      side: const BorderSide(
                          color: Color(0xFF00C896), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Row (Only show if pending)
          if (order.orderStatus.toLowerCase() == 'pending')
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          // Accept Order logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF1E293B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text("Accept Order",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () =>
                            _confirmOrder(order.orderId.toString()),
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
                            Text("Confirm Order",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(width: 8),
                            Icon(Icons.check_circle, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  "Order Status: ${order.orderStatus.toUpperCase()}",
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _infoRow(
      {required IconData icon,
      required String title,
      required String content,
      String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFE2FBE9),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF00C896), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 4),
              Text(content,
                  style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 13)),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
