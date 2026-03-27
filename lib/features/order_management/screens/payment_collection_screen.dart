import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/orders/barrel.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:viraeshop_admin/features/order_management/screens/agent_settlement_screen.dart';

class PaymentCollectionScreen extends StatefulWidget {
  static const String path = '/payment_collection';
  final Orders? order;
  final OrderTask? task;

  const PaymentCollectionScreen({super.key, this.order, this.task});

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'Cash';
  bool _handoverConfirmed = false;
  double _amountToCollect = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      // Prioritize due balance, fallback to codAmountToCollect or subTotal
      _amountToCollect = (widget.order!.due != 0.0)
          ? widget.order!.due.toDouble()
          : (widget.order!.codAmountToCollect ??
              widget.order!.subTotal.toDouble());

      // Ensure amount is not negative
      if (_amountToCollect < 0) _amountToCollect = 0.0;

      _amountController.text = _amountToCollect.toStringAsFixed(0);
    }
    _amountController.addListener(() {
      setState(() {}); // trigger rebuild for partial payment warning
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_handoverConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please confirm product handover",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent));
      return;
    }

    final collected = double.tryParse(_amountController.text) ?? 0.0;

    context.read<OrdersBloc>().add(UpdateOrderEvent(
          orderId: widget.order!.orderId!.toString(),
          token: Hive.box('adminInfo').get('token'),
          orderModel: {
            'deliveryStatus': 'completed',
            'notificationType': 'admin2Customer',
            'paymentMethod': _selectedMethod,
            'codAmountCollected': collected,
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    double currentInput = double.tryParse(_amountController.text) ?? 0.0;
    bool isPartial = currentInput < _amountToCollect;
    double diff = _amountToCollect - currentInput;

    return BlocListener<OrdersBloc, OrderState>(
      listener: (context, state) {
        if (state is RequestFinishedOrderState &&
            state.response.message == 'Task Completed') {
          // Store context's navigator before popping
          final navigator = Navigator.of(context);
          
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Delivery Completed!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("Funds added to your cash in hand.",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF1E293B), // Dark Navy for premium look
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'DEPOSIT NOW',
              textColor: const Color(0xFF00C896), // Teal accent
              onPressed: () {
                navigator.pushNamed(AgentSettlementScreen.path);
              },
            ),
          ));
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (state is OnErrorOrderState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.redAccent));
        }
      },
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Payment Collection",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Order #${widget.order?.orderId ?? 'Pending'} • ${widget.order?.customer.name ?? ''}",
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE2FBE9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.help_outline,
                  color: Color(0xFF00C896), size: 18),
            ),
          ],
        ),
        body: widget.order == null
            ? const Center(child: Text("No active delivery selected"))
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handover Checkbox Card
                        GestureDetector(
                          onTap: () => setState(
                              () => _handoverConfirmed = !_handoverConfirmed),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ]),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                      color: _handoverConfirmed
                                          ? const Color(0xFF00C896)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _handoverConfirmed
                                            ? const Color(0xFF00C896)
                                            : const Color(0xFFCBD5E1),
                                        width: 2,
                                      )),
                                  child: _handoverConfirmed
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Product Handover Confirmed",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF1E293B))),
                                      const SizedBox(height: 4),
                                      const Text(
                                          "Confirm you have handed the items to the customer before collecting payment.",
                                          style: TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 13,
                                              height: 1.4)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        const Text("PAYMENT DETAILS",
                            style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0)),
                        const SizedBox(height: 12),

                        // Expected Amount Box
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Expected Amount",
                                      style: TextStyle(
                                          color: Color(0xFF475569),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(_amountToCollect.toStringAsFixed(0),
                                          style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0F172A))),
                                      const SizedBox(width: 8),
                                      const Text("BDT",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A))),
                                    ],
                                  ),
                                ],
                              ),
                              const Icon(Icons.payments,
                                  color: Color(0xFF00C896), size: 28),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text("Amount Received",
                            style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        // Input Field
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              suffixText: "BDT",
                              suffixStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Partial Payment Error Notice
                        if (isPartial)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFFEF3C7)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFD97706), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Partial Payment Detected",
                                          style: TextStyle(
                                              color: Color(0xFFB45309),
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                              color: Color(0xFFB45309),
                                              fontSize: 13),
                                          children: [
                                            const TextSpan(text: "Remaining "),
                                            TextSpan(
                                                text:
                                                    "${diff.toStringAsFixed(0)} BDT",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    decoration: TextDecoration
                                                        .underline)),
                                            const TextSpan(
                                                text:
                                                    " will be marked as Due."),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Payment Methods
                        const Text("Payment Method",
                            style: TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child:
                                    _paymentMethodCard('Cash', Icons.payments)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _paymentMethodCard(
                                    'bKash', Icons.account_balance_wallet)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _paymentMethodCard(
                                    'Nagad', Icons.phone_android)),
                          ],
                        ),

                        const SizedBox(height: 40),

                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey[300],
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.5)
                                        ])),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                right: 16,
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Delivery Location: ${widget.order?.shippingAddress ?? 'Unknown'}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  // Bottom Complete Button
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, -5))
                        ],
                      ),
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Complete Delivery",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.check_circle, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _paymentMethodCard(String method, IconData icon) {
    bool isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C896) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: const Color(0xFF00C896).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF00C896)
                    : const Color(0xFF64748B),
                size: 24),
            const SizedBox(height: 8),
            Text(method,
                style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF00C896)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
