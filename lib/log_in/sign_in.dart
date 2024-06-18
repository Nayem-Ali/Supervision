import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supervision/log_in/sign_up.dart';
import 'package:supervision/utility/bottom_navigation.dart';
import 'package:supervision/utility/constant_login.dart';
import 'package:supervision/utility/logo.dart';
import 'package:supervision/utility/reusable_button.dart';
import 'forget_password.dart';
import 'main_page.dart';

class SigninPage extends StatefulWidget {
  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isTrue = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Logo(fontSize: 18, width: 100, height: 70),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Email';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: _isTrue,
                controller: password,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isTrue = !_isTrue;
                        });
                      },
                      icon: Icon(
                          _isTrue ? Icons.visibility_off : Icons.visibility)),
                  border: const OutlineInputBorder(),
                  hintText: "Password",
                ),
                validator: (value) {
                  if (value!.isEmpty){
                    return "Enter Password";

                }
                  return null;
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  nextScreen(context, forgetPassword());
                },
                child: Text(
                  'Forgot Password?',
                  style: kTextStyle,
                ),
              ),
            ),
            Button(
              buttonName: "Log In",
              onPressed: () async {
                try {
                  await _auth
                      .signInWithEmailAndPassword(
                    email: email.text.trim(),
                    password: password.text.trim(),
                  )
                      .then((value) async{
                    if(value.user!.emailVerified){
                      replaceScreen(context, const BottomNavigation());
                    }
                    else{
                      await value.user?.sendEmailVerification().whenComplete(() {
                       showSnackBar(context, "Please verify your email first");
                      });

                    }
                  });
                } on FirebaseException catch (e) {
                  if (_formKey.currentState!.validate()) {}
                  showSnackBar(context, e.message);
                  print(e.message);
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Text(
                    textAlign: TextAlign.right,
                    "Did not have an account?",
                    style: GoogleFonts.firaCode(),
                  ),
                ),
                InkWell(
                  child: Text("Sign Up", style: kTextStyle),
                  onTap: () {
                    nextScreen(context, signUp());
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
