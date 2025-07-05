import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class HeadingTextField extends StatefulWidget {
  final bool onMaxLine;
  final TextEditingController controller;
  final String? heading;
  final bool enable;
  final TextInputType keyboardType;
  const HeadingTextField({super.key, 
    required this.onMaxLine,
    required this.controller,
    this.heading,
    this.enable = true,
    this.keyboardType = TextInputType.text,
  });
  @override
  _HeadingTextFieldState createState() => _HeadingTextFieldState();
}

class _HeadingTextFieldState extends State<HeadingTextField> {
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        widget.heading!,
        style: kProductNameStylePro,
      ),
      Container(
        height: 40.0,
        width: MediaQuery.of(context).size.width * 0.4,
        margin: const EdgeInsets.all(10.0),
        child: Center(
          child: TextFormField(
            enabled: widget.enable,
            controller: widget.controller,
            cursorColor: kMainColor,
            style: kProductNameStylePro,
            textInputAction: TextInputAction.done,
            keyboardType: widget.keyboardType,
            maxLines: widget.onMaxLine == true ? 3 : 1,
            decoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kMainColor),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: kMainColor),
              ),
              focusColor: kMainColor,
            ),
            // onFieldSubmitted: (value) {
            //   setState(() => {isEditable = false, title = value});
            // }
          ),
        ),
      ),
    ]);
  }
}
