import 'package:flutter/material.dart';

SliverGridDelegateWithFixedCrossAxisCount responsiveGridDelegate(
  BuildContext context, {
  required int crossAxisCount,
  required double contentHeight,
  double imageAspectRatio = 0,
  double crossAxisSpacing = 12,
  double mainAxisSpacing = 12,
  double horizontalPadding = 32,
}) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final itemWidth =
      (screenWidth -
          horizontalPadding -
          crossAxisSpacing * (crossAxisCount - 1)) /
      crossAxisCount;
  final imageHeight = imageAspectRatio > 0 ? itemWidth / imageAspectRatio : 0.0;
  final textScale = MediaQuery.textScalerOf(context).scale(1.0);

  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisSpacing: mainAxisSpacing,
    mainAxisExtent: imageHeight + contentHeight * textScale,
  );
}
