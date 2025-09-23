import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart'; // 👈 added

import 'screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Allow screenshots globally
  await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookmyshow clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
