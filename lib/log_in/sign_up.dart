import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supervision/log_in/sign_in.dart';
import 'package:supervision/pages/attendance/ML/Recognition.dart';
import 'package:supervision/pages/attendance/databaseService/dbService.dart';
import 'package:supervision/utility/constant_login.dart';
import 'package:supervision/utility/logo.dart';
import 'package:supervision/utility/reusable_button.dart';

import '../pages/attendance/RegistrationScreen.dart';

class signUp extends StatefulWidget {
  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController initialController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final phoneRegex = RegExp(r'^01[3-9][0-9]{8}$');

  bool _supervisor = false;
  bool _student = false;
  bool _isEnable = false;
  bool _isTrue = true;
  bool _isPaused = true;
  bool _isRegistered = false;

  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  void createUser() async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      )
          .then((userInfo) async {
        if (_student == true) {
          faceRegister(userInfo.user!.uid);
          while (_isPaused) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
        await userInfo.user?.sendEmailVerification().whenComplete(() {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Email verification Message is sent"),
                  content: Text(
                      "To login with your account please verify your email ${userInfo.user!.email} first."),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("OK")),
                  ],
                );
              });
        });

        if (_supervisor) {
          await _fireStore
              .collection("users")
              .doc("${userInfo.user?.uid}")
              .set({
            "isSupervisor": _supervisor,
            "phone": phoneController.text,
            "name": nameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "user_id": userInfo.user?.uid,
            "initial": initialController.text,
            "groups": [],
            "imageUrl": ""
          });
          await _fireStore
              .collection("schedule")
              .doc(initialController.text.toUpperCase())
              .set({
            "meetings": [],
          });
        } else {
          await _fireStore
              .collection("users")
              .doc("${userInfo.user?.uid}")
              .set({
            "isSupervisor": _supervisor,
            "phone": phoneController.text,
            "name": nameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "user_id": userInfo.user?.uid,
            "student_id": idController.text,
            "groups": [],
            "imageUrl": "",
          });
        }
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

  faceRegister(String uid) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Face Registration"),
            content: const Text(
                "To create account as a student you need register your face first."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RegistrationScreen(uid: uid)));
                  },
                  child: const Text("Register")),
               TextButton(
                  onPressed: () {
                    setState(() {
                      _isPaused = false;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Ok")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        ///resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              //mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Logo(fontSize: 20, height: 80, width: 100),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0, top: 12),
                        child: TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Name",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Email",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Email';
                            } else if (!emailRegex.hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Phone",
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter Phone Number';
                          } else if (!phoneRegex.hasMatch(value)) {
                            return "Enter a valid phone number";
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Container(
                            margin:
                                const EdgeInsets.only(left: 12.0, right: 12.0),
                            child: Checkbox(
                              value: _supervisor,
                              activeColor: const Color(0xFF104D5B),
                              onChanged: (bool? value) {
                                setState(() {
                                  _supervisor = value!;
                                  _student = false;
                                  _isEnable = value;
                                });
                              },
                            ),
                          ),
                          Text(
                            'Supervisor',
                            style: kTextStyle,
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(left: 12.0, right: 12.0),
                            child: Checkbox(
                              value: _student,
                              activeColor: const Color(0xFF104D5B),
                              onChanged: (bool? value) {
                                setState(() {
                                  _student = value!;
                                  _supervisor = false;
                                  _isEnable = value;
                                });
                              },
                            ),
                          ),
                          Text(
                            'Student',
                            style: kTextStyle,
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: TextFormField(
                          controller: _supervisor == true
                              ? initialController
                              : idController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: _supervisor == true
                                ? 'Enter Your Initial'
                                : "Enter Your Student ID",
                            enabled: _isEnable,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Initial';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        child: TextFormField(
                          obscureText: _isTrue,
                          controller: passwordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isTrue = !_isTrue;
                                  });
                                },
                                icon: Icon(_isTrue
                                    ? Icons.visibility_off
                                    : Icons.visibility)),
                            border: const OutlineInputBorder(),
                            hintText: "Password",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Password';
                            }

                            return null;
                          },
                        ),
                      ),
                      Text(
                        'Must be at least 6 characters',
                        textAlign: TextAlign.left,
                        style: kTextStyle,
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 12.0, top: 12),
                        child: TextFormField(
                          obscureText: _isTrue,
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isTrue = !_isTrue;
                                  });
                                },
                                icon: Icon(_isTrue
                                    ? Icons.visibility_off
                                    : Icons.visibility)),
                            border: const OutlineInputBorder(),
                            hintText: "Confirm Password",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Re - type password';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Button(
                  buttonName: 'Sign Up',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (passwordController.text ==
                          confirmPasswordController.text) {
                        createUser();
                      } else {
                        showSnackBar(context, "Password Not Matched");

                        passwordController.clear();
                        confirmPasswordController.clear();
                      }
                    }
                  },
                ),
                Container(
                  margin: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "Already have an account?",
                          style: GoogleFonts.firaCode(),
                        ),
                      ),
                      GestureDetector(
                        child: Text(
                          " Login",
                          style: kTextStyle,
                        ),
                        onTap: () {
                          nextScreen(context, SigninPage());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
