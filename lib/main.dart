import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supervision/splash_screen/splash.dart';
//import 'package:dcdg/dcdg.dart';
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// To interact with flutter engine
  await Firebase.initializeApp(
    name: "Supervision",
    options: const FirebaseOptions(
      apiKey: "AIzaSyDdTm2tW8rjmKARnKhqZrHahEKfc5yEU8k",
      appId: "1:811728969138:android:ad4c824b9dbfe8838898ab",
      messagingSenderId: "811728969138",
      projectId: "supervision-5227e",
      storageBucket: "gs://supervision-5227e.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
