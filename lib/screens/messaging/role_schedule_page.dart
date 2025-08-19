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
 final TextEditingController controller = TextEditingController();

 @override
  void initState() {
    // TODO: implement initState
    controller.text = widget.schedule.message;
   super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      isThreeLine: true,
      secondary: Icon(
        widget.schedule.isEnabled
            ? Icons.notifications_active
            : Icons.notifications_off,
        color: widget.schedule.isEnabled ? kNewMainColor : Colors.red,
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      title: Row(
        children: [
          Text(
            widget.schedule.dayOfWeek,
            style: kProductNameStylePro,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (!controller.text.contains('{name}')) {
                  controller.text += '{name}';
                }
              });
            },
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

          const SizedBox(width: 6), // কম gap

          // Wallet Button (only for agents)
          if (widget.role == 'agents')
            TextButton(
              onPressed: () {
                setState(() {
                  if (!controller.text.contains('{wallet}')) {
                    controller.text += '{wallet}';
                  }
                });
              },
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

          if (widget.role == 'agents') const SizedBox(width: 6), // কম gap

          // Due Button
          TextButton(
            onPressed: () {
              setState(() {
                if (!controller.text.contains('{due}')) {
                  controller.text += '{due}';
                }
                print(controller.text);
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
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
        padding: const EdgeInsets.only(top: 8.0),
        child: TextFormField(
          controller: controller,
          maxLines: 5,
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
            widget.onStart.call();
            BlocProvider.of<ScheduleBloc>(context).add(
              UpdateScheduledEvent(
                notificationId: widget.schedule.id.toString(),
                notificationModel: {
                  'message': value,
                },
                token: widget.token,
              ),
            );
          },
        ),
      ),
      value: widget.schedule.isEnabled,
      onChanged: (value) {
        widget.onStart.call();
        BlocProvider.of<ScheduleBloc>(context).add(
          UpdateScheduledEvent(
              token: widget.token,
              notificationId: widget.schedule.id.toString(),
              notificationModel: {
                'isEnabled': value,
              }),
        );
      },
    );
  }
}
