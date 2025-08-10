import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
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
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLength: 3,
              decoration: InputDecoration(
                hintText: 'Enter message here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            SendButton(
              onTap: () {
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
              title: 'Send Message',
            ),
          ],
        ),
      ),
    );
  }
}
