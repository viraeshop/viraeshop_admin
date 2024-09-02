
import 'package:flutter/material.dart';

import '../../../components/styles/colors.dart';
import '../../../components/styles/text_styles.dart';
import 'chat_profile_image.dart';

class MeChatBubble extends StatelessWidget {
  const MeChatBubble({
    super.key,
    required this.profileImage,
    required this.message,
    required this.time,
  });

  final String? profileImage;
  final String message;
  final String time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: const BoxDecoration(
              color: kNewMainColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    'Me',
                    style: kProductNameStylePro.copyWith(
                      color: orangeA200,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: bodySmall.copyWith(
                          color: kBackgroundColor,
                          height: 1.50,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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
          ChatProfileImage(profileImage: profileImage,),
        ],
      ),
    );
  }
}

