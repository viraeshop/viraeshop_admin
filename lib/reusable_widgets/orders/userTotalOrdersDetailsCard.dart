import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

import '../../screens/orders/customer_orders.dart';
import '../general/profile_image.dart';

class UserTotalOrderDetailsCard extends StatelessWidget {
  const UserTotalOrderDetailsCard({Key? key, required this.info})
      : super(key: key);
  final Map<String, dynamic> info;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    if (kDebugMode) {
      print(info);

    }return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerOrders(
              title: info['name'],
              info: info,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 150.0,
              width: screenSize.width * 0.85,
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 10.0,
                right: 10.0,
                left: 110.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '${info['name']}'.toNameCase(),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: kGreenText.copyWith(
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          'Orders  ${info['total']}',
                          style: kSansTextStyleSmallBlack,
                        ),
                        Text(
                          'Pending  ${info['pendings']}',
                          style: kSansTextStyleSmallBlack,
                        ),
                        Text(
                          'Confirmed  ${info['confirmed']}',
                          style: kSansTextStyleSmallBlack,
                        ),
                        Text(
                          'Canceled  ${info['canceled']}',
                          style: kSansTextStyleSmallBlack,
                        ),
                        Text(
                          'Failed  ${info['failed']}',
                          style: kSansTextStyleSmallBlack,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          info['role'],
                          style: kSansTextStyleBigBlack,
                        ),
                        const Text(
                          'New Order',
                          style: kBigBrownText,
                        ),
                        Text(
                          '${info['newOrders']}',
                          style: kGreenText,
                        ),
                        // Text(
                        //   'now',
                        //   style: kSansTextStyleSmallBlack,
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 50.0,
            left: 10,
            child: ProfileImage(
              image: info['profileImage'] ?? '',
            ),
          ),
        ],
      ),
    );
  }
}

extension NameCase on String {
  String toNameCase() {
    if (isEmpty) return this;

    return split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
