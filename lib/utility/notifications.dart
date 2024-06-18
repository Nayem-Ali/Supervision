import 'package:flutter/material.dart';
import 'package:supervision/utility/bottom_navigation.dart';
import 'package:supervision/utility/constant_login.dart';

import '../screens/color_all.dart';

class Notifications extends StatelessWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            // Here we write a code for Profile
            nextScreen(context, const BottomNavigation());
          },
        ),
        backgroundColor: kAppBarColor,
        title: const Text("Notifications"),
      ),
      body: const Center(
        child: Text("Upcoming"),

      ),
    );
  }
}
