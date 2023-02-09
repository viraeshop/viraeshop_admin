import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class NewTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;
  final bool secure;
  final int lines;
  final dynamic prefix;
  final dynamic prefixIcon;
  final Widget? suffixIcon;
  final String hintText;
  final String helperText;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final int? maxLength;
  final TextInputType keyboardType;
 const NewTextField({
   this.suffixIcon,
   this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.prefix,
    this.readOnly = false,
    this.lines = 1,
    this.hintText = '',
    this.helperText = '',
    this.labelText = '',
    this.validator,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.secure = false,
    required this.controller,
    Key? key,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      onTap: onTap,
      style: kTableCellStyle,
      cursorColor: kNewTextColor,
      obscureText: secure,
      readOnly: readOnly,
      maxLines: lines,
      validator: validator,
      maxLength: maxLength,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        prefixStyle: kTableCellStyle,
        prefixText: prefix,
        prefixIcon: prefixIcon,
        hintText: hintText,
        suffixIcon: suffixIcon,
        labelStyle: kTableCellStyle,
        labelText: labelText,
        hintStyle: kTableCellStyle,
        helperText: helperText,
        helperStyle: const TextStyle(
          fontSize: 12.0,
          color: kNewTextColor,
          fontFamily: 'SourceSans',
        ),
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
