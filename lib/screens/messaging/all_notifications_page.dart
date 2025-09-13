import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/send_button.dart';
import 'package:viraeshop_bloc/notifications/notifications.dart';

class AllNotificationsPage extends StatefulWidget {
  const AllNotificationsPage(
      {super.key, required this.onStart, required this.onDone});
  final VoidCallback onStart;
  final VoidCallback onDone;
  @override
  State<AllNotificationsPage> createState() => _AllNotificationsPageState();
}

class _AllNotificationsPageState extends State<AllNotificationsPage> {
  final TextEditingController controller = TextEditingController();
  final token = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is RequestFinishedNotificationState) {
          widget.onDone.call();
          snackBar(
            text: state.response.message,
            context: context,
          );
        } else if (state is OnErrorNotificationState) {
          widget.onDone.call();
          snackBar(
            text: state.message,
            context: context,
            color: Colors.red,
            duration: 600,
          );
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              maxLength: 160,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter message here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            SendButton(
              onTap: () {
                if (controller.text.isEmpty) {
                  snackBar(
                    text: 'Message cannot be empty',
                    context: context,
                  );
                  return;
                }
                widget.onStart.call();
                BlocProvider.of<NotificationBloc>(context).add(
                  CreateNotificationEvent(
                    notificationModel: {
                      'message': controller.text
                    },
                    token: token,
                  ),
                );
              },
              width: 300,
              color: kNewMainColor,
              title: 'Send Message',
            ),
          ],
        ),
      ),
    );
  }
}
