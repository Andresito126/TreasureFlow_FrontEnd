import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:treasureflow/app.dart';
import 'package:treasureflow/core/di/app_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = await AppContainer.create();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => MyApp(container: container),
    ),
  );
}