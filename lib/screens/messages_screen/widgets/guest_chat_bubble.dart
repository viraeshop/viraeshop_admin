import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

import 'chat_profile_image.dart';

class GuestMessage extends StatelessWidget {
  const GuestMessage({
    super.key,
    required this.profileImage,
    required this.message,
    required this.time,
    required this.customerName,
  });
  final String message;
  final String time;
  final String? profileImage;
  final String customerName;
  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      // verticalDirection: VerticalDirection.down,
      children: [
        ChatProfileImage(
          profileImage: profileImage,
        ),
        Container(
          margin: const EdgeInsets.only(
            left: 16,
            top: 10,
            bottom: 10,
          ),
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: gray100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        customerName,
                        style: kProductNameStylePro.copyWith(
                          color: orangeA200,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Customer',
                      style: bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        message,
                        style: bodySmall.copyWith(
                          color: indigo900,
                          height: 1.50,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: bodySmall.copyWith(
                      color: blueBlackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
