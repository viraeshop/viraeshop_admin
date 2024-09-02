import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

import '../../../components/styles/text_styles.dart';
import 'chat_profile_image.dart';

class ChatImageWidget extends StatelessWidget {
  const ChatImageWidget({super.key, required this.url, required this.time, required this.isGuest, required this.profileImage});
  final String url;
  final String time;
  final bool isGuest;
  final String profileImage;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isGuest ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: isGuest ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          if(isGuest)ChatProfileImage(profileImage: profileImage),
          Container(
            height: 300,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(url),
                fit: BoxFit.fill,
              ),
              border: Border.all(color: kSubMainColor, width: 3.0,),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  color: kBlackColor,
                  padding: const EdgeInsets.all(3),
                  child: Text(
                    time,
                    style: bodySmall.copyWith(
                      color: gray100,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if(!isGuest)ChatProfileImage(profileImage: profileImage,),
        ],
      ),
    );
  }
}