import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class NewTextField extends StatelessWidget {
  final TextEditingController controller;
  bool readOnly;
  int lines;
  dynamic prefix;
  dynamic prefixIcon;
  String hintText, helperText, labelText;
  String? Function(String?)? validator;
  NewTextField({
    this.prefixIcon = null,
    this.prefix = null,
    this.readOnly = false,
    this.lines = 1,
    this.hintText = '',
    this.helperText = '',
    this.labelText = '',
    this.validator,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: kTableCellStyle,
      cursorColor: kNewTextColor,
      readOnly: readOnly,
      maxLines: lines,
      validator: validator,
      decoration: InputDecoration(
        prefixStyle: kTableCellStyle,
        prefixText: prefix,
        prefixIcon: prefixIcon,
        hintText: hintText,
        labelStyle: kTableCellStyle,
        labelText: labelText,
        hintStyle: kTableCellStyle,
        helperText: helperText,
        helperStyle: TextStyle(
          fontSize: 12.0,
          color: kNewTextColor,
          fontFamily: 'SourceSans',
        ),
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(10.0),
        //   borderSide: BorderSide(
        //     color: kBlackColor,
        //     width: 3.0,
        //   ),
        // ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: kRedColor,
           // width: 3.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: kNewTextColor,
           // width: 3.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: kBlackColor,
           // width: 3.0,
          ),
        ),
      ),
    );
  }
}
