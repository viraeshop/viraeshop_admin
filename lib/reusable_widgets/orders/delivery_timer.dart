import 'dart:async';
import 'package:flutter/material.dart';
import 'package:viraeshop_api/models/orders/order_task.dart';

class DeliveryTimer extends StatefulWidget {
  final OrderTask? task;
  final bool compact;

  const DeliveryTimer({
    super.key,
    this.task,
    this.compact = false,
  });

  @override
  State<DeliveryTimer> createState() => _DeliveryTimerState();
}

class _DeliveryTimerState extends State<DeliveryTimer> {
  Timer? _timer;
  late Duration _remaining;
  bool _isOverdue = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
  }

  void _updateTime() {
    if (widget.task == null ||
        widget.task?.startTime == null ||
        widget.task?.deadline == null) {
      _remaining = Duration.zero;
      return;
    }

    final now = DateTime.now();
    final deadline = widget.task!.deadline!;

    if (now.isAfter(deadline)) {
      _remaining = now.difference(deadline);
      _isOverdue = true;
    } else {
      _remaining = deadline.difference(now);
      _isOverdue = false;
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task == null || widget.task?.taskStatus != 'active') {
      if (widget.task?.taskStatus == 'pending') {
        return _buildPill(
          context,
          label: "READY",
          value: "${widget.task?.durationMinutes ?? 0}m est.",
          color: const Color(0xFF64748B), // Slate 500
        );
      }
      return const SizedBox.shrink();
    }

    final color = _isOverdue
        ? const Color(0xFFEF4444) // Red 500
        : (_remaining.inMinutes < 5
            ? const Color(0xFFF59E0B) // Amber 500
            : const Color(0xFF10B981)); // Emerald 500

    return _buildPill(
      context,
      label: _isOverdue ? "DELAY" : "TIME LEFT",
      value: _formatDuration(_remaining),
      color: color,
    );
  }

  Widget _buildPill(BuildContext context,
      {required String label, required String value, required Color color}) {
    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black, // Dark professional background
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Icon(_isOverdue ? Icons.warning_amber_rounded : Icons.timer_outlined,
              color: color, size: 28),
        ],
      ),
    );
  }
}
