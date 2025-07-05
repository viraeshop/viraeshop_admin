import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

import '../../components/styles/colors.dart';

class CustomerPreferences {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<String> _hintTexts = [
    'Name',
    'Mobile',
    'Email',
    'Address',
  ];
  final List<IconData> _iconData = [
    Icons.person,
    Icons.phone_android,
    Icons.email,
    Icons.room,
  ];

  List<TextEditingController> get getControllers => _controllers;
  List<String> get getHint => _hintTexts;
  List<IconData> get getIconData => _iconData;
  set addControllers(TextEditingController controller) =>
      _controllers.add(controller);
  set addHint(String text) => _hintTexts.add(text);
  set addIconData(IconData icon) => _iconData.add(icon);
  void addAll(
      {required List<String> hints,
      required List<TextEditingController> controller,
      required List<IconData> icons}) {
    _hintTexts.addAll(hints);
    _iconData.addAll(icons);
    _controllers.addAll(controller);
  }
}
dynamic toast({required BuildContext context,required String title,Color color = kNewTextColor}) {
  return showToast(
    title,
    backgroundColor: color,
    context: context,
    animation: StyledToastAnimation.scale,
    reverseAnimation: StyledToastAnimation.fade,
    position: StyledToastPosition.top,
    animDuration: const Duration(seconds: 1),
    duration: const Duration(seconds: 4),
    curve: Curves.elasticOut,
    reverseCurve: Curves.linear,
  );
}