import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  // Create a 1024x1024 icon
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);

  // Background - gradient blue
  final paint = Paint()
    ..shader = ui.Gradient.linear(
      Offset(0, 0),
      Offset(1024, 1024),
      [
        Color(0xFF1E88E5), // Blue
        Color(0xFF00ACC1), // Teal
      ],
    );

  // Draw rounded rect background
  final rrect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, 1024, 1024),
    Radius.circular(200),
  );
  canvas.drawRRect(rrect, paint);

  // Draw checkmark/approval icon
  final checkPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 80
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  final path = Path();
  path.moveTo(280, 512);
  path.lineTo(420, 660);
  path.lineTo(744, 364);

  canvas.drawPath(path, checkPaint);

  // Add small accent circle
  final accentPaint = Paint()
    ..color = Color(0xFFFFFFFF).withOpacity(0.3)
    ..style = PaintingStyle.fill;

  canvas.drawCircle(Offset(824, 200), 60, accentPaint);

  // Convert to image
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Save to file
  final file = File('assets/icon/app_icon.png');
  await file.writeAsBytes(buffer);

  // Also save foreground version (with transparent background for adaptive icon)
  final recorder2 = ui.PictureRecorder();
  final canvas2 = Canvas(recorder2);

  // Just the checkmark in the center
  canvas2.drawPath(path.shift(Offset(0, 0)), checkPaint);

  final picture2 = recorder2.endRecording();
  final image2 = await picture2.toImage(1024, 1024);
  final byteData2 = await image2.toByteData(format: ui.ImageByteFormat.png);
  final buffer2 = byteData2!.buffer.asUint8List();

  final file2 = File('assets/icon/app_icon_foreground.png');
  await file2.writeAsBytes(buffer2);

  print('Icons created successfully!');
  print('app_icon.png: ${file.path}');
  print('app_icon_foreground.png: ${file2.path}');
}
