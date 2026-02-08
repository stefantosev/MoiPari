import 'package:flutter/material.dart';

class ColorUtils {
  static final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.deepOrange,
  ];

  static Color fromString(String colorName, BuildContext context) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'pink':
        return Colors.pink;
      case 'indigo':
        return Colors.indigo;
      case 'brown':
        return Colors.brown;
      case 'deeporange':
        return Colors.deepOrange;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}