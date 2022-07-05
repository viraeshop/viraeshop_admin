import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import '../../reusable_widgets/buttons/dialog_button.dart';
import 'customer_info.dart';

class NewCustomerInfoScreen extends StatefulWidget {
  final Map<String, dynamic> info;
  NewCustomerInfoScreen({required this.info});

  @override
  State<NewCustomerInfoScreen> createState() => _NewCustomerInfoScreenState();
}

class _NewCustomerInfoScreenState extends State<NewCustomerInfoScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.info['name'],
            style: kAppBarTitleTextStyle,
          ),
          elevation: 3.0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(FontAwesomeIcons.chevronLeft),
            iconSize: 20.0,
            color: kSubMainColor
          ),
          backgroundColor: kBackgroundColor,
        ),
        body: CustomerInfoScreen(
          info: widget.info,
          isNew: true,
        ),
      ),
    );
  }
}