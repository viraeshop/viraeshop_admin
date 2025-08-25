import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_api/models/notifications/schedule/schedule.dart';
import 'package:viraeshop_bloc/notifications/notifications.dart';

class RoleSchedulePage extends StatefulWidget {
  const RoleSchedulePage({
    super.key,
    required this.onStart,
    required this.onDone,
    required this.role,
  });

  final VoidCallback onStart;
  final VoidCallback onDone;
  final String role;

  @override
  State<RoleSchedulePage> createState() => _RoleSchedulePageState();
}

class _RoleSchedulePageState extends State<RoleSchedulePage> {
  List<Schedule> schedules = [];
  final String token = Hive.box('adminInfo').get('token');

  @override
  void initState() {
    super.initState();
    // Load schedules on start
    BlocProvider.of<ScheduleBloc>(context).add(
      GetScheduledEvents(token: token, role: widget.role),
    );
    // Notify parent that loading started
    SchedulerBinding.instance.addPostFrameCallback((_) {
      widget.onStart.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is FetchedSchedulesState) {
          widget.onDone.call();
          setState(() {
            schedules = state.notifications.result;
          });
        } else if (state is RequestFinishedScheduleState) {
          // After any update, refetch list
          BlocProvider.of<ScheduleBloc>(context).add(
            GetScheduledEvents(token: token, role: widget.role),
          );
        } else if (state is OnErrorScheduleState) {
          widget.onDone.call();
          snackBar(
            text: state.message,
            color: Colors.red,
            duration: 600,
            context: context,
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: ListView(
          children: [
            for (var schedule in schedules)
              ScheduleWidget(
                schedule: schedule,
                token: token,
                role: widget.role,
                onStart: widget.onStart,
              ),
          ],
        ),
      ),
    );
  }
}

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({
    super.key,
    required this.schedule,
    required this.token,
    required this.onStart,
    required this.role,
  });

  final String role;
  final Schedule schedule;
  final String token;
  final VoidCallback onStart;

  @override
  State<ScheduleWidget> createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  late final TextEditingController controller;
  late final FocusNode _focusNode;

  /// Track last saved value to avoid duplicate updates.
  String _lastSaved = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.schedule.message ?? '';
    controller = TextEditingController(text: initial);
    _lastSaved = initial;

    _focusNode = FocusNode();

    // Auto-save when keyboard hides / field loses focus.
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveIfChanged();
      }
    });
  }

  /// If Bloc updates the message from outside, sync the field
  /// when not focused (prevents cursor jumps).
  @override
  void didUpdateWidget(covariant ScheduleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.schedule.message ?? '';
    if (!_focusNode.hasFocus && nextText != controller.text) {
      controller.text = nextText;
      _lastSaved = nextText;
    }
  }

  /// Append placeholder tokens without duplicates and keep cursor at end.
  void _appendToken(String token) {
    final text = controller.text;
    if (!text.contains(token)) {
      controller.text = '$text$token';
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
      setState(() {});
    }
  }

  /// Save only if value actually changed (empty allowed).
  void _saveIfChanged() {
    final value = controller.text;
    if (value == _lastSaved) return;

    widget.onStart.call();
    BlocProvider.of<ScheduleBloc>(context).add(
      UpdateScheduledEvent(
        token: widget.token,
        notificationId: widget.schedule.id.toString(),
        notificationModel: {'message': value},
      ),
    );
    _lastSaved = value;
  }

  /// Toggle handler for isEnabled.
  void _onEnabledChanged(bool value) {
    widget.onStart.call();
    BlocProvider.of<ScheduleBloc>(context).add(
      UpdateScheduledEvent(
        token: widget.token,
        notificationId: widget.schedule.id.toString(),
        notificationModel: {'isEnabled': value},
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ListTile + trailing Switch so only the switch toggles.
    return ListTile(
      isThreeLine: true,
      leading: Icon(
        widget.schedule.isEnabled
            ? Icons.notifications_active
            : Icons.notifications_off,
        color: widget.schedule.isEnabled ? kNewMainColor : Colors.red,
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),

      // No toggle on whole row
      onTap: null,

      title: Row(
        children: [
          Text(
            widget.schedule.dayOfWeek,
            style: kProductNameStylePro,
          ),
          TextButton(
            onPressed: () => _appendToken('{name}'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Name',
              style: kProductNameStylePro.copyWith(
                fontSize: 13.0,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (widget.role == 'agents')
            TextButton(
              onPressed: () => _appendToken('{wallet}'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Wallet',
                style: kProductNameStylePro.copyWith(
                  fontSize: 13.0,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (widget.role == 'agents') const SizedBox(width: 6),
          TextButton(
            onPressed: () => _appendToken('{due}'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Due',
              style: kProductNameStylePro.copyWith(
                fontSize: 13.0,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: TextFormField(
          controller: controller,
          focusNode: _focusNode,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Enter message here',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          // Close keyboard -> focus listener will auto-save.
          onEditingComplete: () => FocusScope.of(context).unfocus(),
          onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
          // Flutter 3.3+: tap outside -> close keyboard -> auto-save.
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
      ),

      trailing: Switch.adaptive(
        value: widget.schedule.isEnabled,
        onChanged: _onEnabledChanged,
      ),
    );
  }
}
