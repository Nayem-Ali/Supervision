import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supervision/pages/initial_page.dart';
import 'package:supervision/utility/constant_login.dart';
import 'package:supervision/utility/logo.dart';

import 'color_all.dart';
import 'group_list.dart';

class GroupRegisterPage extends StatefulWidget {
  const GroupRegisterPage({Key? key}) : super(key: key);

  @override
  State<GroupRegisterPage> createState() => _GroupRegisterPageState();
}

class _GroupRegisterPageState extends State<GroupRegisterPage> {
  TextEditingController groupName = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? _selectedProjectCategory;
  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  Future createGroup() async {
    try {
      DocumentReference documentReference = groupCollection.doc();

      documentReference.set({
        "groupName": groupName.text,
        "category": _selectedProjectCategory,
        "members": [currentUser],
        "tasks": [],
        "attendance": [],
        "admin": currentUser
      }).whenComplete(() {
        FirebaseFirestore.instance.collection("users").doc(currentUser).update({
          "groups": FieldValue.arrayUnion([documentReference.id])
        });
        nextScreen(context, InitialPage(groupId: documentReference.id, groupName: groupName.text));
      });

      showSnackBar(context, "Group Created Successfully");

    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

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
            nextScreen(context, const GroupListBar());
          },
        ),
        backgroundColor: kAppBarColor,
        title: const Text("Set up a Group"),
      ),
      resizeToAvoidBottomInset: true,
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Logo(fontSize: 20, height: 100, width: 100),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text(
                    "Set Up a Group",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextFormField(
                    controller: groupName,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: "Project Name"),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter project name";
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  height: 60,
                  width: 370,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      alignment: Alignment.centerRight,
                      hint: const Text(
                        "Select Project Category",
                        textAlign: TextAlign.center,
                      ),
                      value: _selectedProjectCategory,
                      items: const [
                        DropdownMenuItem<String>(
                          value: "3rd Year Project",
                          child: Text("3rd Year Project"),
                        ),
                        DropdownMenuItem<String>(
                          value: "4th Year Project",
                          child: Text("4th Year Project"),
                        ),
                        DropdownMenuItem<String>(
                          value: "Thesis",
                          child: Text("Thesis"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectCategory = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if(formKey.currentState!.validate() && _selectedProjectCategory!.isNotEmpty){
                      createGroup();
                    }
                    else{
                      showSnackBar(context, "Provide Necessary Information");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor
                  ),
                  child: const Text("Create"),
                )
              ],
            ),
          ),
        ),
      ),
      //bottomNavigationBar: const BottomNav2(),
    );
  }
}

