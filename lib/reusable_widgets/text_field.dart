import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class NewTextField extends StatelessWidget {
  final TextEditingController controller;
  bool readOnly;
  final bool? secure;
  int lines;
  dynamic prefix;
  dynamic prefixIcon;
  String hintText, helperText, labelText;
  String? Function(String?)? validator;
  final int? maxLength;
  NewTextField({
    this.prefixIcon = null,
    this.prefix = null,
    this.readOnly = false,
    this.lines = 1,
    this.hintText = '',
    this.helperText = '',
    this.labelText = '',
    this.validator,
    this.maxLength,
    this.secure = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: kTableCellStyle,
      cursorColor: kNewTextColor,
      obscureText: secure!,
      readOnly: readOnly,
      maxLines: lines,
      validator: validator,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixStyle: kTableCellStyle,
        prefixText: prefix,
        prefixIcon: prefixIcon,
        hintText: hintText,
        labelStyle: kTableCellStyle,
        labelText: labelText,
        hintStyle: kTableCellStyle,
        helperText: helperText,
        helperStyle: const TextStyle(
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
          borderSide: const BorderSide(
            color: kRedColor,
           // width: 3.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: kSubMainColor,
           width: 3.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: kBlackColor,
           width: 5.0,
          ),
        ),
      ),
    );
  }
}
