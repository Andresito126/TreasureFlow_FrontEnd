import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerIconFactory {
  static Future<BitmapDescriptor> vehicle({
    required double devicePixelRatio,
    required Color background,
    Color iconColor = Colors.white,
    double logicalSize = 46,
  }) {
    return fromIcon(
      Icons.local_shipping_rounded,
      devicePixelRatio: devicePixelRatio,
      background: background,
      iconColor: iconColor,
      logicalSize: logicalSize,
    );
  }

  static Future<BitmapDescriptor> fromIcon(
    IconData icon, {
    required double devicePixelRatio,
    required Color background,
    Color iconColor = Colors.white,
    double logicalSize = 46,
  }) async {
    final size = logicalSize * devicePixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = size / 2;
    final center = Offset(radius, radius);

    canvas.drawCircle(
      center.translate(0, size * 0.02),
      radius - size * 0.06,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    canvas.drawCircle(
      center,
      radius - size * 0.08,
      Paint()..color = background,
    );

    canvas.drawCircle(
      center,
      radius - size * 0.08,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.07,
    );

    final painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.48,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: iconColor,
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(radius - painter.width / 2, radius - painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: devicePixelRatio,
    );
  }
}
