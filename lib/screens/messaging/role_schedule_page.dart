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
  const RoleSchedulePage(
      {super.key,
      required this.onStart,
      required this.onDone,
      required this.role});
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
    BlocProvider.of<ScheduleBloc>(context).add(
      GetScheduledEvents(token: token, role: widget.role),
    );
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onStart.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is FetchedSchedulesState) {
          print(state.notifications.result.length);
          widget.onDone.call();
          setState(() {
            schedules = state.notifications.result;
          });
        } else if (state is RequestFinishedScheduleState) {
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
                onStart: widget.onStart,
              ),
          ],
        ),
      ),
    );
  }
}

class ScheduleWidget extends StatelessWidget {
  const ScheduleWidget(
      {super.key,
      required this.schedule,
      required this.token,
      required this.onStart});
  final Schedule schedule;
  final String token;

  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      isThreeLine: true,
      secondary: Icon(
        schedule.isEnabled
            ? Icons.notifications_active
            : Icons.notifications_off,
        color: schedule.isEnabled ? kNewMainColor : Colors.red,
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      title: Text(
        schedule.dayOfWeek,
        style: kProductNameStylePro,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextFormField(
          initialValue: schedule.message,
          decoration: InputDecoration(
            hintText: 'Enter message here',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onFieldSubmitted: (value) {
            if (value.isEmpty) {
              snackBar(
                text: 'Message cannot be empty',
                context: context,
              );
              return;
            }
            onStart.call();
            BlocProvider.of<ScheduleBloc>(context).add(
              UpdateScheduledEvent(
                notificationId: schedule.id.toString(),
                notificationModel: {
                  'message': value,
                },
                token: token,
              ),
            );
          },
        ),
      ),
      value: schedule.isEnabled,
      onChanged: (value) {
        onStart.call();
        BlocProvider.of<ScheduleBloc>(context).add(
          UpdateScheduledEvent(
              token: token,
              notificationId: schedule.id.toString(),
              notificationModel: {
                'isEnabled': value,
              }),
        );
      },
    );
  }
}
