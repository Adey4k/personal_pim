import 'package:flutter/material.dart';

const int maxGroupCount = 15;

class GroupStyle {
  static Color colorFor(BuildContext context, String groupName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hash = groupName.hashCode & 0x7fffffff;
    final anchorColors = <Color>[
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Color.lerp(colorScheme.primary, colorScheme.secondary, 0.45)!,
      Color.lerp(colorScheme.secondary, colorScheme.tertiary, 0.45)!,
      Color.lerp(colorScheme.tertiary, colorScheme.primary, 0.45)!,
    ];

    final base = HSLColor.fromColor(anchorColors[hash % anchorColors.length]);
    final hueShift = (((hash ~/ anchorColors.length) % 5) - 2) * 10.0;
    final saturation = (base.saturation * 0.75 + 0.22)
        .clamp(0.38, 0.64)
        .toDouble();

    return HSLColor.fromAHSL(
      1.0,
      (base.hue + hueShift) % 360,
      saturation,
      0.42,
    ).toColor();
  }

  static Color foregroundFor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black87;
  }
}
