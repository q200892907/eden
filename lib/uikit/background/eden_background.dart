import 'package:eden/uikit/theme/eden_theme_extension.dart';
import 'package:eden_uikit/eden_uikit.dart';
import 'package:flutter/material.dart';

enum EdenBackgroundType {
  normal, //默认
}

class EdenBackground extends StatelessWidget {
  const EdenBackground({
    super.key,
    required this.child,
    this.type = EdenBackgroundType.normal,
  });

  final Widget child;
  final EdenBackgroundType type;

  Decoration get _decoration1 {
    switch (type) {
      case EdenBackgroundType.normal:
        return BoxDecoration(
          gradient: EdenThemeBuilder.theme.backgroundBottomLinearGradient,
        );
      default:
        return const BoxDecoration();
    }
  }

  Decoration get _decoration2 {
    switch (type) {
      case EdenBackgroundType.normal:
        return BoxDecoration(
          gradient: EdenThemeBuilder.theme.backgroundTopLinearGradient,
        );
      default:
        return const BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: _decoration1,
          ),
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: _decoration2,
          ),
          child,
        ],
      ),
    );
  }
}
