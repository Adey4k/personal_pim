import 'package:flutter/material.dart';

const int maxGroupCount = 15;

class GroupStyle {
  static Color colorFor(BuildContext context, String groupName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hash = groupName.hashCode & 0x7fffffff;
    final primaryHue = HSLColor.fromColor(colorScheme.primary).hue;
    const hueOffsets = <double>[
      0.0,
      137.5,
      275.0,
      52.5,
      190.0,
      327.5,
      105.0,
      242.5,
      20.0,
      157.5,
      295.0,
      72.5,
      210.0,
      347.5,
      125.0,
    ];

    final hueJitter = (((hash ~/ hueOffsets.length) % 7) - 3) * 3.0;
    final hue =
        (primaryHue + hueOffsets[hash % hueOffsets.length] + hueJitter) % 360;
    final isDark = theme.brightness == Brightness.dark;
    final saturation = (isDark ? 0.62 : 0.58) + (hash % 5) * 0.025;
    final lightness = isDark ? 0.58 : 0.43;

    final color = HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
    return Color.lerp(color, colorScheme.primary, isDark ? 0.06 : 0.1)!;
  }

  static Color foregroundFor(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black87;
  }
}
