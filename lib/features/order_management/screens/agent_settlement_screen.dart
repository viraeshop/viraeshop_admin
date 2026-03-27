import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:viraeshop_bloc/processing/processing_bloc.dart';
import 'package:viraeshop_bloc/processing/processing_event.dart';
import 'package:viraeshop_bloc/processing/processing_state.dart';

class AgentSettlementScreen extends StatefulWidget {
  static const String path = '/agent_settlement';
  final String? adminId;

  const AgentSettlementScreen({super.key, this.adminId});

  @override
  State<AgentSettlementScreen> createState() => _AgentSettlementScreenState();
}

class _AgentSettlementScreenState extends State<AgentSettlementScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();
  double _currentCashInHand = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  void _fetchStats() {
    final token = Hive.box('adminInfo').get('token') ?? '';
    final aid =
        widget.adminId ?? Hive.box('adminInfo').get('adminId')?.toString() ?? '';
    if (aid.isNotEmpty) {
      context.read<ProcessingBloc>().add(GetSettlementStatsEvent(
            adminId: aid,
            token: token,
          ));
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptImage = File(image.path);
      });
    }
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount != _currentCashInHand) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Deposit amount must be exactly equal to Cash in Hand (${_currentCashInHand.toStringAsFixed(0)} BDT).",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange.shade700,
      ));
      return;
    }
    if (_receiptNoController.text.isEmpty || _receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields and upload a receipt.",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    final token = Hive.box('adminInfo').get('token') ?? '';
    final aid =
        widget.adminId ?? Hive.box('adminInfo').get('adminId')?.toString() ?? '';

    setState(() {
      isLoading = true;
    });

    Future.microtask(() async {
      try {
        final uploadResult = await NetworkUtility.uploadImageFromNative(
          file: PlatformFile(
            path: _receiptImage!.path,
            name: _receiptImage!.path.split('/').last,
            size: await _receiptImage!.length(),
          ),
          folder: 'settlements',
        );

        if (mounted) {
          context.read<ProcessingBloc>().add(SubmitBulkSettlementEvent(
                adminId: aid,
                amount: amount,
                receiptNo: _receiptNoController.text,
                receiptImage: uploadResult['url'] ?? '',
                notes: "Submitted via App",
                token: token,
              ));
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Upload failed: $e"),
            backgroundColor: Colors.redAccent,
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Settlement",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
            onPressed: () {
              _fetchStats();
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: BlocConsumer<ProcessingBloc, ProcessingState>(
        listener: (context, state) {
          if (state is ProcessingSuccess && state.isSettlement) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Settlement Submitted Successfully"),
              backgroundColor: Color(0xFF00C896),
            ));
            Navigator.pop(context);
          } else if (state is ProcessingError) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Error: ${state.message}"),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 5),
            ));
          }
        },
        builder: (context, state) {
          double totalCollected = 0.0;
          double cashInHand = 0.0;
          if (state is ProcessingStatsLoaded) {
            totalCollected = state.totalCollectedToday;
            cashInHand = state.cashInHand;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _currentCashInHand != cashInHand) {
                setState(() {
                  _currentCashInHand = cashInHand;
                });
              }
            });
          }

          return BlurryModalProgressHUD(
            inAsyncCall: isLoading || state is ProcessingLoading,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Collected\nToday",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF475569))),
                                  const SizedBox(height: 12),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text:
                                                "${totalCollected.toStringAsFixed(0)} ",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B))),
                                        const TextSpan(
                                            text: "BDT",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2FBE9),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFBBEBCE)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Cash in Hand",
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF00C896),
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 28),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text:
                                                "${cashInHand.toStringAsFixed(0)} ",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B))),
                                        const TextSpan(
                                            text: "BDT",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text("New Settlement Deposit",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      const Text("Submit your collected cash to the treasury",
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF00C896))),
                      const SizedBox(height: 24),
                      const Text("Deposit Amount",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            color: Color(0xFF1E293B), fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "0.00",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            child: Text("BDT",
                                style: TextStyle(
                                    color: Color(0xFF00C896),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFF00C896))),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Receipt Number",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _receiptNoController,
                        style: const TextStyle(
                            color: Color(0xFF1E293B), fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Enter transaction or receipt ID",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Color(0xFF00C896))),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Upload Receipt Image",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFBBEBCE), width: 1.5),
                          ),
                          child: _receiptImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(_receiptImage!,
                                      fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        color: Color(0xFF00C896), size: 36),
                                    SizedBox(height: 12),
                                    Text("Tap to take a photo or upload",
                                        style: TextStyle(
                                            color: Color(0xFF00C896),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(height: 6),
                                    Text("PNG, JPG UP TO 10MB",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info, color: Colors.grey, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Settlements are verified by the central finance team within 24 hours. Please keep your physical receipts until the status is marked as 'Approved'.",
                                style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    height: 1.5),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          spreadRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C896),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.send, size: 20),
                      label: const Text("Submit Settlement",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
