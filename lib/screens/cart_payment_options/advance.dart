import 'package:flutter/material.dart';

import '../../components/styles/colors.dart';

class TypableText extends StatelessWidget {
  const TypableText({
    Key? key,
    required this.isDesc,
    required this.controller,
    required this.switchOn,
    required this.switchOff,
    required this.onChanged,
    required this.keyboardType
  }) : super(key: key);
  final bool isDesc;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final void Function()? switchOn;
  final void Function()? switchOff;
  final void Function(String)? onChanged;
  @override
  Widget build(BuildContext context) {
    if (!isDesc) {
      return TextButton(
        onPressed: switchOn,
        child: Text(
          'Advance: ${controller.text}',
          style: const TextStyle(
            color: kSubMainColor,
            fontFamily: 'Montserrat',
            fontSize: 15,
            letterSpacing: 1.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: TextField(
            cursorColor: kMainColor,
            style: const TextStyle(
              color: kSubMainColor,
              fontFamily: 'Montserrat',
              fontSize: 20,
              letterSpacing: 1.3,
            ),
            onChanged: onChanged,
            textAlign: TextAlign.center,
            keyboardType: keyboardType,
            controller: controller,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: kMainColor),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kMainColor),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kMainColor, width: 2.0),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.done,
                  color: kSubMainColor,
                  size: 20.0,
                ),
                onPressed: switchOff,
              ),
            ),
          ));
    }
  }
}
