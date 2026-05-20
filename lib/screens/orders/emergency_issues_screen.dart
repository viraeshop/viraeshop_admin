import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/customers/tabWidgets.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';
import '../../reusable_widgets/orders/functions.dart';

class EmergencyIssuesScreen extends StatefulWidget {
  const EmergencyIssuesScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyIssuesScreen> createState() => _EmergencyIssuesScreenState();
}

class _EmergencyIssuesScreenState extends State<EmergencyIssuesScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final Map<String, dynamic> filterInfo = {
      'filterType': 'emergency',
      'filterData': {},
      'offSet': 0,
    };
    Provider.of<OrderProvider>(context, listen: false).updateFilterInfo(filterInfo);
    Provider.of<OrderProvider>(context, listen: false).updateOrderStage(OrderStages.processing);
    getOrders(data: filterInfo, context: context);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 20),
          color: kBlackColor,
        ),
        title: const Text(
          'Emergency & Supplier Issues',
          style: kTotalSalesStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 10.0),
                    LimitedBox(
                      maxHeight: screenSize.height * 0.85,
                      child: const OrdersTab(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

