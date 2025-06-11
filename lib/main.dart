import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:sportify_gym_porject/screens/admin/home_screen.dart';
import 'package:sportify_gym_porject/screens/home_screen.dart';
import 'package:sportify_gym_porject/screens/intro_screen.dart';
import 'package:sportify_gym_porject/utils/app_theme.dart';
import 'package:sportify_gym_porject/utils/cache_helper.dart';

import 'firebase_options.dart';

Future<void> setupFirebaseMessaging() async {
  // Request notification permissions
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Subscribe to all users topic
    await FirebaseMessaging.instance.subscribeToTopic('all_users');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the received message
      print('Received message: ${message.notification?.title}');
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the opened app message
      print('Message opened app: ${message.notification?.title}');
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  setupFirebaseMessaging();
  await CacheHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Widget? screen;
  if (CacheHelper.getData(key: "login") == "admin") {
    screen = AdminHomeScreen();
  } else if (FirebaseAuth.instance.currentUser != null) {
    screen = HomeScreen();
  } else {
    screen = IntroScreen();
  }
  runApp(GymApp(
    cameras: cameras,
    screen: screen,
  ));
}

class GymApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final Widget screen;

  const GymApp({
    Key? key,
    required this.cameras,
    required this.screen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Gym Trainer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: screen,
    );
  }
}
