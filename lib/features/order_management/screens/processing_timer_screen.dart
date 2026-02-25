import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/processing/processing_bloc.dart';
import 'package:viraeshop_bloc/processing/processing_event.dart';
import 'package:viraeshop_bloc/processing/processing_state.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';

class ProcessingTimerScreen extends StatefulWidget {
  static const String path = '/processing_timer';
  final OrderTask? task;

  const ProcessingTimerScreen({super.key, this.task});

  @override
  State<ProcessingTimerScreen> createState() => _ProcessingTimerScreenState();
}

class _ProcessingTimerScreenState extends State<ProcessingTimerScreen> {
  late Timer _timer;
  late Duration _remainingTime;
  late Duration _totalDuration;

  @override
  void initState() {
    super.initState();
    if (widget.task == null) return;

    // Initialize Timer Logic
    final startTime = widget.task!.startTime ?? DateTime.now();
    _totalDuration = Duration(minutes: widget.task!.durationMinutes ?? 60);
    final deadline = startTime.add(_totalDuration);

    final now = DateTime.now();
    if (now.isAfter(deadline)) {
      _remainingTime = Duration.zero;
    } else {
      _remainingTime = deadline.difference(now);
    }

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          } else {
            _timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  double _calculateProgress() {
    if (_totalDuration.inSeconds == 0) return 0.0;
    return _remainingTime.inSeconds / _totalDuration.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessingBloc, ProcessingState>(
      listener: (context, state) {
        if (state is ProcessingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Task Completed!"),
              backgroundColor: const Color(0xFF00C896)));
          Navigator.pop(context); // Go back on success
        } else if (state is ProcessingError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.redAccent));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Dark Theme Workspace
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Workspace",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            )
          ],
        ),
        body: widget.task == null
            ? const Center(
                child: Text("No active task selected",
                    style: TextStyle(color: Colors.white)))
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Timer Section
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 280,
                              height: 280,
                              child: CircularProgressIndicator(
                                value: _calculateProgress(),
                                strokeWidth: 16,
                                backgroundColor: const Color(0xFF1E293B),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _remainingTime.inSeconds < 300
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF00C896)),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Remaining Time",
                                  style: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDuration(_remainingTime),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                            "Target", "${widget.task!.durationMinutes} min"),
                      ],
                    ),

                    const Spacer(flex: 1),

                    // Task Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF334155)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ]),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334155),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.inventory_2_outlined,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFF00C896)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                        "Order #${widget.task!.orderId}",
                                        style: const TextStyle(
                                            color: Color(0xFF00C896),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold))),
                                const SizedBox(height: 8),
                                Text(
                                    "${(widget.task!.taskType ?? 'Standard').toUpperCase()} TASK",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<ProcessingBloc>().add(CompleteTaskEvent(
                                taskId: widget.task!.id!,
                                token: Hive.box('adminInfo').get('token'),
                              ));
                        },
                        icon: const Icon(Icons.check_circle, size: 24),
                        label: const Text("Mark as Complete"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C896),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton.icon(
                        onPressed: () {
                          _showDelayDialog(context);
                        },
                        icon: const Icon(Icons.report_problem_outlined,
                            color: Color(0xFFF87171)),
                        label: const Text("Report Delay",
                            style: TextStyle(
                                color: Color(0xFFF87171),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFEF2F2).withOpacity(0.05),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color ?? Colors.white)),
      ],
    );
  }

  void _showDelayDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text("Report Delay",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              content: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Reason for delay...",
                  hintStyle: const TextStyle(color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel",
                        style: TextStyle(color: Color(0xFF94A3B8)))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        context.read<ProcessingBloc>().add(ReportDelayEvent(
                              taskId: widget.task!.id!,
                              reason: controller.text,
                              token: Hive.box('adminInfo').get('token'),
                            ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text("Submit",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ));
  }
}
