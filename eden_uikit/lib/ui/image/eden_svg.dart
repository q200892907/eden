import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ZhiyaSvg extends StatelessWidget {
  const ZhiyaSvg({
    super.key,
    required this.path,
    this.size,
    this.color,
    this.package,
  });

  final String path;
  final Size? size;
  final Color? color;
  final String? package;

  @override
  Widget build(BuildContext context) {
    return _svgWidget(
      path,
      size: size,
      color: color,
      package: package,
    );
  }
}

Widget _svgWidget(String path, {Size? size, Color? color, String? package}) {
  if (size != null) {
    return SizedBox.fromSize(
      size: size,
      child: SvgPicture.asset(
        path,
        colorFilter:
            color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
        package: package,
      ),
    );
  } else {
    return SvgPicture.asset(
      path,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      package: package,
    );
  }
}
