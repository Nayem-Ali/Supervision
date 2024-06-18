import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supervision/log_in/sign_in.dart';
import 'package:supervision/screens/color_all.dart';
import 'package:supervision/utility/bottom_navigation.dart';
import 'package:supervision/utility/constant_login.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async{
                  FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.signOut();
                  replaceScreen(context, SigninPage());
                },
                child: Container(
                  height: MediaQuery.of(context).size.height/17,
                  width: MediaQuery.of(context).size.width,
                  //padding:
                      //const EdgeInsets.symmetric(horizontal: 157, vertical: 10),
                  //margin: const EdgeInsets.only(bottom: 20),
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    /*borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),*/
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 20,),
                          Icon(Icons.logout),
                          SizedBox(width: 10,),
                          Text("Log out"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
