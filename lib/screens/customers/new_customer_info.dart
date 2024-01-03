import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/customers/customers_bloc.dart';
import 'package:viraeshop_bloc/customers/customers_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

import 'customer_info.dart';

class NewCustomerInfoScreen extends StatefulWidget {
  final Map<String, dynamic> info;
  const NewCustomerInfoScreen({required this.info, Key? key}) : super(key: key);

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
      progressIndicator: const CircularProgressIndicator(
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
            onPressed: () {
              final customerBloc = BlocProvider.of<CustomersBloc>(context);
              final jWTToken = Hive.box('adminInfo').get('token');
              customerBloc.add(GetCustomersEvent(
                  token: jWTToken,
                  query: 'all', isNewRequest: 'true'));
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
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