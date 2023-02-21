import 'package:flutter/material.dart';

import 'colors.dart';

const Gradient kLinearGradient = LinearGradient(
    colors: [
      kNewMainColor,
      Color(0xFF6ad5b4),
    ],
    begin: FractionalOffset(1.0, 0.0),
    end: FractionalOffset(0.0, 0.0),
    stops: [0.0, 1.0],
    tileMode: TileMode.clamp,
);
