import 'package:flutter/material.dart';

extension EdenThemeDataExtension on ThemeData {
  LinearGradient get backgroundBottomLinearGradient => const LinearGradient(
        colors: [
          Color(0x43FF78D6),
          Color(0x4CC853FF),
          Color(0xA1C9C8FF),
        ],
        end: Alignment.centerRight,
        begin: Alignment.centerLeft,
      );

  LinearGradient get backgroundTopLinearGradient => LinearGradient(
        colors: [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0.7),
          Colors.white.withOpacity(1),
        ],
        end: Alignment.bottomCenter,
        begin: Alignment.topCenter,
      );

  LinearGradient get buttonLinearGradient => const LinearGradient(
        colors: [
          Color(0xffD884FF),
          Color(0xffB9A1FF),
        ],
        end: Alignment.centerRight,
        begin: Alignment.centerLeft,
      );
}
