
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/customers/customer_list.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

class ArchitectsPage extends StatefulWidget {
  const ArchitectsPage({Key? key}) : super(key: key);

  @override
  _ArchitectsPageState createState() => _ArchitectsPageState();
}

class _ArchitectsPageState extends State<ArchitectsPage> {
  GeneralCrud generalCrud = GeneralCrud();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'Architects',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
      ),
      body: const Customers(
        role: 'architect',
      ),
    );
  }
}
