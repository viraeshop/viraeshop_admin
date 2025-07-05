import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: kMainColor, width: 2.0),
  ),
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  hintStyle: kProductNameStylePro,
  border: InputBorder.none,
);

const kSendButtonTextStyle = TextStyle(
  color: kMainColor,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

final BoxDecoration kBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: const [
    BoxShadow(
      offset: Offset(0, 0),
      color: Colors.black38,
      blurRadius: 1.0,
    ),
    BoxShadow(
      offset: Offset(0, 0),
      color: Colors.black38,
      blurRadius: 1.0,
    ),
  ],
  color: kBackgroundColor,
);
