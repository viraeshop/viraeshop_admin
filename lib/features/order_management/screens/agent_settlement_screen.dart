import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_bloc/processing/processing_bloc.dart';
import 'package:viraeshop_bloc/processing/processing_event.dart';
import 'package:viraeshop_bloc/processing/processing_state.dart';

class AgentSettlementScreen extends StatefulWidget {
  static const String path = '/agent_settlement';
  final String? adminId; // The ID of the logged-in agent

  const AgentSettlementScreen({super.key, this.adminId});

  @override
  State<AgentSettlementScreen> createState() => _AgentSettlementScreenState();
}

class _AgentSettlementScreenState extends State<AgentSettlementScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptImage = File(image.path);
      });
    }
  }

  void _submit() {
    if (_amountController.text.isEmpty ||
        _receiptNoController.text.isEmpty ||
        _receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all fields and upload receipt")));
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    // Convert image to base64 or upload to S3/Firebase first?
    // For this prototype, we'll send the path or assume the API handles multipart.
    // However, OrderLifecycleApi.submitBulkSettlement expects a String receiptImage.
    // Usually this means a URL or Base64. Let's assume path for now or Base64 string if easy.
    // I'll send the path string, but in production this needs real upload logic.

    context.read<ProcessingBloc>().add(SubmitBulkSettlementEvent(
        adminId: widget.adminId ?? '',
        amount: amount,
        receiptNo: _receiptNoController.text,
        receiptImage: _receiptImage!.path, // basic path for now
        notes: _notesController.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<ProcessingBloc, ProcessingState>(
      listener: (context, state) {
        if (state is ProcessingSuccess && state.isSettlement) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Settlement Submitted Successfully")));
          Navigator.pop(context);
        } else if (state is ProcessingError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Agent Settlement"),
          backgroundColor: kNewMainColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: kNewMainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kNewMainColor.withOpacity(0.3))),
                child: Column(
                  children: [
                    Text("Cash in Hand (Estimated)",
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text("৳ 0.00",
                        style: theme.textTheme.headlineMedium?.copyWith(
                            color: kNewMainColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        "Please deposit the total cash collected to the office/bank and upload the receipt here.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey))
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Form
              Text("Deposit Details",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount Deposited",
                  prefixText: "৳ ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _receiptNoController,
                decoration: const InputDecoration(
                  labelText: "Transaction/Receipt No",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Image Upload
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        style: BorderStyle.solid),
                  ),
                  child: _receiptImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_receiptImage!, fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt,
                                size: 32, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text("Upload Receipt Image",
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey))
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Notes (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 32),

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
                  child: const Text("Submit Settlement"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
