import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_bloc/admin/admin_bloc.dart';
import 'package:viraeshop_bloc/admin/admin_event.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/reusable_widgets/send_button.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/admins/admin_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_api/models/admin/admins.dart';

final auth = FirebaseAuth.instance;

void showAuthDialog(BuildContext context) {
  final TextEditingController controller = TextEditingController();
  showDialog(
    barrierColor: Colors.black12,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Authentication Required!',
          style: kProductNameStylePro,
        ),
        content: NewTextField(
          controller: controller,
          keyboardType: TextInputType.number,
          secure: true,
        ),
        actions: [
          Consumer<AdminProvider>(builder: (context, admin, any) {
            return SendButton(
              onTap: () async {
                FocusScope.of(context).unfocus();
                snackBar(
                  text: 'Updating please wait',
                  context: context,
                  duration: 600,
                );
                final adminBloc = BlocProvider.of<AdminBloc>(context);
                final jWTToken = Hive.box('adminInfo').get('token');
                try {
                  final user = await auth.signInWithEmailAndPassword(
                      email: admin.oldEmail, password: controller.text);
                  await user.user
                      ?.updateEmail(admin.email)
                      .then((value) => Navigator.pop(context));
                  adminBloc.add(
                    UpdateAdminEvent(
                      token: jWTToken,
                      adminId: admin.adminInfo['adminId'],
                      adminModel: AdminModel.fromJson(admin.adminInfo),
                    ),
                  );
                } on FirebaseException catch (e) {
                  debugPrint(e.message);
                  snackBar(
                    text: e.message!,
                    context: context,
                    duration: 600,
                    color: kRedColor,
                  );
                }
              },
              title: 'Update',
              color: kNewMainColor,
            );
          })
        ],
      );
    },
  );
}
