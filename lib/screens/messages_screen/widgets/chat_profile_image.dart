import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

import '../../../reusable_widgets/image/custom_image_viewer.dart';

class ChatProfileImage extends StatelessWidget {
  const ChatProfileImage({
    super.key,
    required this.profileImage,
  });

  final String? profileImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      margin: const EdgeInsets.only(
        left: 7,
        //top: 82.v,
      ),
      child: Stack(
        //alignment: Alignment.bottomRight,
        children: [
          CustomImageView(
            imagePath: profileImage,
            height: 40,
            width: 40,
            radius: BorderRadius.circular(
              20,
            ),
            alignment: Alignment.center,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: kLightGreen,
                borderRadius: BorderRadius.circular(
                  6,
                ),
                border: Border.all(
                  color: kBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}