import 'package:flutter/material.dart';

class MenuPositionHelper {
  static RelativeRect calculatePosition({
    required GlobalKey key,
    required BuildContext context,
    double horizontalOffset = -30,
    double verticalOffset = 10,
  }) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return RelativeRect.fill;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return RelativeRect.fromLTRB(
      offset.dx + horizontalOffset,
      offset.dy + buttonSize.height + verticalOffset,
      screenWidth - (offset.dx + buttonSize.width - horizontalOffset),
      screenHeight - (offset.dy + buttonSize.height + verticalOffset),
    );
  }
}
