import 'package:flutter/widgets.dart';

class MenuPositionHelper {
  static RelativeRect calculatePosition({
    required BuildContext context,
  }) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return RelativeRect.fill;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    return RelativeRect.fromLTRB(
      offset.dx - 100, // Left position (centered under icon)
      offset.dy + buttonSize.height + 8, // Position below icon
      screenSize.width - (offset.dx + buttonSize.width + 100), // Right position
      screenSize.height - offset.dy - buttonSize.height - 8, // Bottom position
    );
  }
}
