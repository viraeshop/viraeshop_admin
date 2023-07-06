import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

import '../components/styles/text_styles.dart';

class OnErrorWidget extends StatelessWidget {
  const OnErrorWidget({Key? key, required this.message, this.onRefresh})
      : super(key: key);

  final String message;
  final void Function()? onRefresh;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          message,
          style: kSansTextStyleSmallBlack,
        ),
        const SizedBox(
          height: 10.0,
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(FontAwesomeIcons.arrowsRotate),
          color: kNewMainColor,
          iconSize: 25.0,
        ),
      ],
    );
  }
}
