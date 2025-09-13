import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/extensions/string.dart';
import 'package:viraeshop_admin/screens/orders/order_provider.dart';

import '../../components/styles/colors.dart';

class OrderDropdown extends StatelessWidget {
  const OrderDropdown({Key? key, required this.value, required this.onChanged})
      : super(key: key);
  final String value;
  final void Function(String?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      //width: 100.0,
      height: 40,
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: kNewMainColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Consumer<OrderProvider>(builder: (context, provider, any) {
        return DropdownButton(
          dropdownColor: kNewMainColor,
          iconEnabledColor: kBackgroundColor,
          underline: const SizedBox(),
          items: dropdownItemsGenerator(provider.currentStage),
          value: value,
          onChanged: onChanged,
        );
      }),
    );
  }
}

List<DropdownMenuItem<String>>? dropdownItemsGenerator(OrderStages stages) {
  if (stages == OrderStages.order) {
    List<String> itemsTitle = [
      'All',
      'Pending',
      'Confirmed',
      'Canceled',
      'Failed'
    ];
    List<DropdownMenuItem<String>>? dropdownItems = itemsTitle.map((e) {
      return DropdownMenuItem<String>(
        value: e.toLowerCase(),
        child: Text(
          e,
          style: kSansTextStyleWhite1,
        ),
      );
    }).toList();
    return dropdownItems;
  } else if (stages == OrderStages.processing) {
    List<String> itemsTitle = [
      'All',
      'Pending',
      'Confirmed',
      'Canceled',
    ];
    List<DropdownMenuItem<String>>? dropdownItems = itemsTitle.map((e) {
      return DropdownMenuItem(
        value: e.toLowerCase(),
        child: Text(
          e,
          style: kSansTextStyleWhite1,
        ),
      );
    }).toList();
    return dropdownItems;
  } else {
    List<String> itemsTitle = [
      'receiveStatus',
      'deliveryStatus',
    ];
    List<DropdownMenuItem<String>>? dropdownItems = itemsTitle.map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(
          e.split('S')[0].capitalize(),
          style: kSansTextStyleWhite1,
        ),
      );
    }).toList();
    return dropdownItems;
  }
}

