import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_bloc/processing/processing_bloc.dart';
import 'package:viraeshop_bloc/processing/processing_event.dart';
import 'package:viraeshop_bloc/processing/processing_state.dart';
import 'package:viraeshop_api/models/orders/orders.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

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
      _amountToCollect = widget.order!.codAmountToCollect ??
          widget.order!.total.toDouble() ??
          0.0;
      _amountController.text = _amountToCollect.toStringAsFixed(0);
    }
  }

  void _submit() {
    if (!_handoverConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please confirm product handover")));
      return;
    }

    final collected = double.tryParse(
            _amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;

    context.read<ProcessingBloc>().add(CompleteTaskEvent(
            taskId: widget.task!.id!,
            token: Hive.box('adminInfo').get('token'),
            paymentDetails: {
              'amountCollected': collected,
              'method': _selectedMethod
            }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<ProcessingBloc, ProcessingState>(
      listener: (context, state) {
        if (state is ProcessingSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.popUntil(
              context, (route) => route.isFirst); // Go back to Home
        } else if (state is ProcessingError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Complete Delivery"),
          backgroundColor: kNewMainColor,
        ),
        body: widget.order == null
            ? const Center(child: Text("No active delivery selected"))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handover Check
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _handoverConfirmed
                                  ? kNewMainColor
                                  : Colors.grey.withOpacity(0.3))),
                      child: CheckboxListTile(
                        value: _handoverConfirmed,
                        onChanged: (v) =>
                            setState(() => _handoverConfirmed = v ?? false),
                        title: const Text("Confirm Handover",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text(
                            "I have handed over the correct items to the customer."),
                        activeColor: kNewMainColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text("Payment Collection",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Amount Input
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: "Amount Collected",
                        prefixText: "৳ ",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        // hintText: _amountToCollect.toStringAsFixed(0)
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (double.tryParse(_amountController.text
                            .replaceAll(RegExp(r'[^0-9.]'), '')) !=
                        _amountToCollect)
                      Text(
                          "Partial Payment Detected: Due ৳ ${(_amountToCollect - (double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0)).toStringAsFixed(0)}",
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold)),

                    const SizedBox(height: 24),

                    // Method Selection
                    Text("Payment Method",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          ['Cash', 'bKash', 'Nagad', 'Rocket'].map((method) {
                        final isSelected = _selectedMethod == method;
                        return ChoiceChip(
                          label: Text(method),
                          selected: isSelected,
                          onSelected: (bp) =>
                              setState(() => _selectedMethod = method),
                          selectedColor: kNewMainColor,
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black),
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 48),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kNewMainColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        child: const Text("Confirm & Complete"),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
