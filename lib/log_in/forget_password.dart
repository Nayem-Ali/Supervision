import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision/utility/constant_login.dart';
import 'package:supervision/utility/reusable_button.dart';


class forgetPassword extends StatelessWidget {
  forgetPassword({Key? key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(20.5),
            child: Text(
              "Forgot Password",
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 25)),
            ),
          ),
          Text(
            "Enter your email associated with your account",
            style: GoogleFonts.lato(
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          Container(
            margin: const EdgeInsets.all(12.0),
            child: Form(
              key: formKey,
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                ),
                validator: (value) {
                  if(value!.isEmpty){
                    return "Enter password reset email";
                  }
                  return null;
                },
              ),
            ),
          ),
          Button(
              buttonName: 'Send',
              onPressed: () async {
                try {
                  if(formKey.currentState!.validate()){
                    await _auth.sendPasswordResetEmail(
                      email: emailController.text.trim(),
                    ).whenComplete(() => showSnackBar(context, "Password Reset email is sent"));
                  }

                } on FirebaseException catch (e) {
                  showSnackBar(context, e.message);
                }
              }),
          Container(
            margin: const EdgeInsets.all(12.0),
            child: Button(
                buttonName: 'Get Back',
                onPressed: ()  {
                  Navigator.pop(context);
                }),
          )
        ],
      ),
    );
  }
}
