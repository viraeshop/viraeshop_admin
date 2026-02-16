import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_bloc/processing/processing_bloc.dart';
import 'package:viraeshop_bloc/processing/processing_event.dart';
import 'package:viraeshop_bloc/processing/processing_state.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<ProcessingBloc, ProcessingState>(
      listener: (context, state) {
        if (state is ProcessingSuccess) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context); // Go back on success
        } else if (state is ProcessingError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Workspace"),
          backgroundColor: kNewMainColor,
        ),
        body: widget.task == null
            ? const Center(child: Text("No active task selected"))
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Timer Section
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 250,
                              height: 250,
                              child: CircularProgressIndicator(
                                value: _calculateProgress(),
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _remainingTime.inSeconds < 300
                                        ? Colors.red
                                        : kNewMainColor),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Remaining",
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                Text(
                                  _formatDuration(_remainingTime),
                                  style: theme.textTheme.displayMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatCard(
                            "Target", "${widget.task!.durationMinutes} min"),
                        const SizedBox(width: 40),
                        _buildStatCard("Efficiency", "94%",
                            color: kNewMainColor),
                      ],
                    ),

                    const Spacer(),

                    // Task Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1a3333) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: kNewMainColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                        "Order #${widget.task!.orderId}",
                                        style: const TextStyle(
                                            color: kNewMainColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold))),
                                const SizedBox(height: 4),
                                Text("Processing Task",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Icon(Icons.inventory_2, color: Colors.grey)
                          ],
                        ),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<ProcessingBloc>()
                              .add(CompleteTaskEvent(widget.task!.id!));
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Mark as Complete"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kNewMainColor,
                            foregroundColor: Colors.white, // Text color
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton.icon(
                      onPressed: () {
                        // Show Dialog to input reason
                        _showDelayDialog(context);
                      },
                      icon: const Icon(Icons.report_problem,
                          color: Colors.redAccent),
                      label: const Text("Report Delay",
                          style: TextStyle(color: Colors.redAccent)),
                    )
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
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _showDelayDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("Report Delay"),
              content: TextField(
                controller: controller,
                decoration:
                    const InputDecoration(hintText: "Reason for delay..."),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        context.read<ProcessingBloc>().add(ReportDelayEvent(
                            widget.task!.id!, controller.text));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text("Submit")),
              ],
            ));
  }
}
