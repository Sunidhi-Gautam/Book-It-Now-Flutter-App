import 'dart:async';
import 'package:bookmyshowclone/screens/siginPage.dart';
import 'package:flutter/material.dart';
import '../../models/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SigninPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            // App Name
            Text(
              "Book It Now",
              style: TextStyle(
                color: lightColor,
                fontFamily: primaryFont,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            LoadingAnimationWidget.waveDots(
              color: const Color.fromARGB(158, 255, 255, 255),
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
