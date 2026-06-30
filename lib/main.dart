import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:treasureflow/app.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/notifications/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final container = await AppContainer.create();
  await NotificationService().initialize();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => MyApp(container: container),
    ),
  );
}