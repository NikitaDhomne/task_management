import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:task_synchro/firebase_options.dart';
import 'package:task_synchro/providers/notification_service.dart';

import 'package:task_synchro/screens/homepage.dart';
import 'package:task_synchro/screens/signIn_screen.dart';
import 'package:task_synchro/screens/signUp_screen.dart';
import 'package:task_synchro/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize(); // Initialize notifications
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
      routes: {
        SignInPage.routeName: (context) => SignInPage(),
        Homepage.routeName: (context) => Homepage(),
        SignUpPage.routeName: (context) => SignUpPage()
      },
    );
  }
}
