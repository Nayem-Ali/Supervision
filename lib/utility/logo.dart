import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision/utility/constant_login.dart';

class Logo extends StatelessWidget {
  final double fontSize;
  final double height;
  final double width;

  const Logo({required this.fontSize, required this.height, required this.width});



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: const AssetImage("images/project.png"),
          height: height,
          width: width,
        ),
        Text(
          "Supervision",
          style: GoogleFonts.lato(
              textStyle: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
            color: kPrimaryColor,
          )),
        )
      ],
    );
  }
}
