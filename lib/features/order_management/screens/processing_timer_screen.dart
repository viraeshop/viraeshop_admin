import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_bloc/items/barrel.dart';
import 'package:viraeshop_api/models/items/items.dart';

class ProcessingTimerScreen extends StatefulWidget {
  static const String path = '/processing_timer';
  final Items? product;
  final String orderId;
  final bool isLastProduct;

  const ProcessingTimerScreen({super.key, required this.orderId, this.product, this.isLastProduct = false});

  @override
  State<ProcessingTimerScreen> createState() => _ProcessingTimerScreenState();
}

class _ProcessingTimerScreenState extends State<ProcessingTimerScreen> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _hasSent70PercentWarning = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.product == null) return;

    // Initialize Timer Logic
    final startTime = widget.product!.startedAt ?? DateTime.now();
    _totalDuration = Duration(minutes: widget.product!.estimatedTime);
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

            // 70% Warning condition
            if (_totalDuration.inSeconds > 0) {
              final double progress =
                  1.0 - (_remainingTime.inSeconds / _totalDuration.inSeconds);
              if (progress >= 0.7 && !_hasSent70PercentWarning) {
                _hasSent70PercentWarning = true;
                context.read<OrderItemsBloc>().add(
                      TriggerTimerNotificationEvent(
                        id: widget.product!.id,
                        type: 'warning',
                        token: Hive.box('adminInfo').get('token'),
                      ),
                    );
              }
            }
          } else {
            _timer?.cancel();
            // Do NOT auto-trigger timeout notification or delay dialog here.
            // The background server cron job will handle sending the timeout push notification.
            // And the user has to explicitly click "Report Delay" to submit the delayed status.
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inDays > 0) {
      String twoDigitHours = twoDigits(duration.inHours.remainder(24));
      return "${twoDigits(duration.inDays)}:$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
    } else if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds";
    }
  }

  double _calculateProgress() {
    if (_totalDuration.inSeconds <= 0) return 0.0;
    return _remainingTime.inSeconds / _totalDuration.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderItemsBloc, OrderItemState>(
      listener: (context, state) {
        if (state is RequestFinishedOrderItemState && _isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Update Successful!"),
              backgroundColor: Color(0xFF00C896)));
          setState(() {
            _isSubmitting = false;
          });
          Navigator.pop(context); // Go back on explicit success
        } else if (state is OnErrorOrderItemState && _isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.redAccent));
          setState(() {
            _isSubmitting = false;
          });
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
        body: widget.product == null
            ? const Center(
                child: Text("No active task selected",
                    style: TextStyle(color: Colors.white, fontSize: 18)))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Context Header
                      Text(
                        "${widget.product!.productName}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Text(
                        "Order #${widget.orderId}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Circular Timer
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: CircularProgressIndicator(
                              value: _calculateProgress(),
                              strokeWidth: 12,
                              backgroundColor: const Color(0xFF1E293B),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF38BDF8)),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDuration(_remainingTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const Text(
                                "REMAINING",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Action Buttons
                      Column(
                        children: [
                          _buildActionButton(
                            label: "MARK AS COMPLETE",
                            icon: Icons.check_circle_outline,
                            color: const Color(0xFF00C896),
                            onTap: () {
                              if (widget.isLastProduct) {
                                _showHubTransitDialog(context);
                              } else {
                                setState(() {
                                  widget.product!.processingStatus = 'completed';
                                  _isSubmitting = true;
                                });
                                context.read<OrderItemsBloc>().add(
                                      UpdateOrderItemEvent(
                                        token: Hive.box('adminInfo').get('token'),
                                        orderModel: {
                                          'id': widget.product!.id,
                                          'itemInfo': {
                                            'processingStatus': 'completed',
                                          },
                                        },
                                      ),
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            label: "REPORT DELAY",
                            icon: Icons.history_rounded,
                            color: const Color(0xFFEF4444),
                            onTap: () => _showDelayDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
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
                        setState(() {
                          widget.product!.processingStatus = 'delayed';
                          widget.product!.note = controller.text;
                          _isSubmitting = true;
                        });
                        context.read<OrderItemsBloc>().add(
                              UpdateOrderItemEvent(
                                token: Hive.box('adminInfo').get('token'),
                                orderModel: {
                                  'id': widget.product!.id,
                                  'itemInfo': {
                                    'processingStatus': 'delayed',
                                    'note': controller.text,
                                  },
                                },
                              ),
                            );
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text("Submit",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ));
  }

  void _showHubTransitDialog(BuildContext context) {
    Duration tempDuration = const Duration(hours: 1); // Default
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Final Batch Complete",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This is the final product for your batch. Please set the estimated time to reach the Receive/Delivery Hub.",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: ThemeData.dark(),
                child: SizedBox(
                   height: 150,
                   child: Material(
                     color: Colors.transparent,
                     child: Padding(
                       padding: const EdgeInsets.only(top: 10),
                       child: Center(
                         child: TextFormField(
                           initialValue: "60",
                           keyboardType: TextInputType.number,
                           style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                           textAlign: TextAlign.center,
                           decoration: const InputDecoration(
                             border: InputBorder.none,
                             suffixText: "min",
                             suffixStyle: TextStyle(color: Colors.white70, fontSize: 16)
                           ),
                           onChanged: (val) {
                             tempDuration = Duration(minutes: int.tryParse(val) ?? 60);
                           },
                         ),
                       ),
                     ),
                   ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                widget.product!.processingStatus = 'completed';
                _isSubmitting = true;
              });
              context.read<OrderItemsBloc>().add(
                UpdateOrderItemEvent(
                  token: Hive.box('adminInfo').get('token'),
                  orderModel: {
                    'id': widget.product!.id,
                    'itemInfo': {
                      'processingStatus': 'completed',
                      'hubDurationMinutes': tempDuration.inMinutes,
                    },
                  },
                ),
              );
            },
            child: const Text("Confirm & Submit", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
