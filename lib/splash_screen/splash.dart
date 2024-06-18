import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:supervision/utility/logo.dart';
import '../log_in/main_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
        animationDuration: const Duration(milliseconds: 30),
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: 300,
        splash: const Logo(fontSize: 20, height: 200, width: 200),
        nextScreen:  const MainPage(),);
  }
}
//MainPage() instead of Home Page