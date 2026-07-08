import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:treasureflow/app.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/notifications/services/notification_service.dart';
import 'package:treasureflow/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = await AppContainer.create();
  await NotificationService().initialize();

  final hasSeenOnboarding = await container.userStorage.hasSeenOnboarding();
  final hasSession = await container.userStorage.hasSession();
  final userType = hasSession ? await container.userStorage.getUserType() : null;

  final String initialLocation;
  if (!hasSeenOnboarding) {
    initialLocation = '/onboardingStep1';
  } else if (hasSession) {
    initialLocation = userType == 'establishment' ? '/homeLocal' : '/homeCitizen';
  } else {
    initialLocation = '/login';
  }

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => MyApp(
        container: container,
        initialLocation: initialLocation,
      ),
    ),
  );
}