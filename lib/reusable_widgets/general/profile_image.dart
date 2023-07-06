import 'package:flutter/material.dart';

import '../../components/styles/colors.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.0,
      width: 120.0,
      decoration: BoxDecoration(
          color: kBackgroundColor,
          image: const DecorationImage(image: AssetImage('assets/images/man.png')),
          border: Border.all(
            width: 3.0,
            color: kNewMainColor,
          ),
          borderRadius: BorderRadius.circular(100.0)
      ),
    );
  }
}