import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  final String buttonName;
  final Function() onPressed;

  const Button({required this.buttonName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      style: ElevatedButton.styleFrom(
        primary: Color(0xFF104D5B),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        maximumSize: Size(300, 50),
        minimumSize: Size(300, 50),
      ),
      child: Text(
        buttonName,
        style: GoogleFonts.sourceSansPro(
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
