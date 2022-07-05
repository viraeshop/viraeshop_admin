import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class EditableTextField extends StatefulWidget {
  final TextStyle textStyle;
  final bool onMaxLine;
  final TextEditingController controller;
  final String? heading;
  EditableTextField({
    required this.textStyle,
    required this.onMaxLine,
    required this.controller,
    this.heading,
  });
  @override
  _EditableTextFieldState createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {
  String title = "MyTitle";
  bool isEditable = false;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.heading!,
            style: widget.textStyle,
          ),
          !isEditable
              ? Expanded(
                  child: Text(
                    widget.controller.text,
                    style: kProductPriceStylePro,
                  ),
                )
              : Expanded(
                  child: TextFormField(
                      controller: widget.controller,
                      cursorColor: kMainColor,
                      // initialValue: title,
                      style: kProductNameStylePro,
                      textInputAction: TextInputAction.done,
                      maxLines: widget.onMaxLine == true ? 3 : 1,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: kMainColor),
                        ),
                        focusColor: kMainColor,
                      ),
                      onFieldSubmitted: (value) {
                        setState(() => {isEditable = false, title = value});
                      }),
                ),
          IconButton(
            icon: Icon(
              isEditable ? Icons.done : Icons.edit,
              size: 20.0,
              color: kIconColor2,
            ),
            onPressed: () {
              setState(() => {
                    isEditable = !isEditable,
                  });
            },
          )
        ]);
  }
}
