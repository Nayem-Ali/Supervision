import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color(0xFF104D5B);

TextStyle kTextStyle =
    GoogleFonts.firaCode(color: kPrimaryColor, fontWeight: FontWeight.bold);

void showSnackBar(context, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      //clipBehavior: ,
      content: Text(
        message,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white),
      ),
      backgroundColor: kPrimaryColor,
      duration: const Duration(seconds: 3),
    ),
  );
}

void nextScreen(context, page) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ));
}

void replaceScreen(context, page) {
  Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),(rout)=>false,
  );
}
