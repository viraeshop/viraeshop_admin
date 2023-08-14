import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../components/styles/colors.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    required this.image,
    Key? key,
  }) : super(key: key);
  final String image;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      width: 120.0,
      decoration: BoxDecoration(
          color: kBackgroundColor,
          image: DecorationImage(
              image: image.isNotEmpty
                  ? CachedNetworkImageProvider(image)
                  : const AssetImage('assets/images/man.png') as ImageProvider),
          border: Border.all(
            width: 3.0,
            color: kNewMainColor,
          ),
          borderRadius: BorderRadius.circular(100.0)),
    );
  }
}
