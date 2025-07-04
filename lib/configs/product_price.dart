import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class ProductPrice extends StatefulWidget {
  final bool isSelected;
  final TextEditingController controller;
  final Function(bool?) onChanged;
  final String? Function(String?)? validator;
  final String title;
  const ProductPrice(
      {super.key, required this.title,
        this.validator,
      required this.isSelected,
      required this.controller,
      required this.onChanged});

  @override
  State<ProductPrice> createState() => _ProductPriceState();
}

class _ProductPriceState extends State<ProductPrice> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CheckboxListTile(
        checkColor: kBackgroundColor,
        activeColor: kBlackColor,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          widget.title,
          style: kTableCellStyle,
        ),
        secondary: SizedBox(
          width: 100.0,
          height: 40.0,
          child: Center(
            child: TextFormField(
              style: kTableCellStyle,
              controller: widget.controller,
              keyboardType: TextInputType.number,
              validator: widget.validator,
              decoration: const InputDecoration(
                // labelText: "Price",
                // labelStyle: kProductNameStylePro,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kBlackColor,),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: kBlackColor,),
                ),
                focusColor: kBlackColor,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kBlackColor,),),
              ),
            ),
          ),
        ),
        value: widget.isSelected,
        onChanged: widget.onChanged,
      ),
    );
  }
}
