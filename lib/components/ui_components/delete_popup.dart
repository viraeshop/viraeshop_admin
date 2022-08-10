import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';

class DeletePopup extends StatelessWidget {
  const DeletePopup({Key? key, required this.onDelete}) : super(key: key);
  final void Function()? onDelete;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Customer'),
      content: const Text(
        'Are you sure you want to remove this customer?',
        softWrap: true,
        style: kSourceSansStyle,
      ),
      actions: [
        TextButton(
          onPressed: onDelete,
          child: const Text(
            'Yes',
            softWrap: true,
            style: kSourceSansStyle,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'No',
            softWrap: true,
            style: kSourceSansStyle,
          ),
        )
      ],
    );
  }
}
