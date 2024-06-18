import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supervision/utility/constant_login.dart';

class RoutinePage extends StatefulWidget {
  bool isSupervisor;

  RoutinePage({Key? key, required this.isSupervisor}) : super(key: key);

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  PlatformFile? pickedFile;
  String url = '';
  final formKey = GlobalKey<FormState>();
  TextEditingController superVisorInitialInput = TextEditingController();
  String superVisorInitial = '';
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  void getFile() {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("schedule")
          .doc(superVisorInitial);
      documentReference.get().then((value) {
        setState(() {
          url = value.get('image_url');
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    checkSupervisor();
  }

  checkSupervisor() {
    if (widget.isSupervisor) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser)
          .get()
          .then((value) {
        setState(() {
          superVisorInitial = value.get("initial");

        });
      });
      getFile();
    }
  }

  Future uploadFile() async {
    try {
      final path = '/routine/${pickedFile!.name}';
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref().child(path);
      ref.putFile(file).whenComplete(() async {
        url = await ref.getDownloadURL();

        FirebaseFirestore.instance
            .collection("schedule")
            .doc(superVisorInitial.toUpperCase())
            .update({"image_url": url}).whenComplete(() => getFile());

        pickedFile = null;
      });
      showSnackBar(context, "File Uploaded Successfully");
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

  Future selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      setState(() {
        pickedFile = result.files.first;
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supervisor Class Routine"),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
      ),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            url != ''
                ? Image.network(url, fit: BoxFit.fill)
                : SizedBox(),
            pickedFile != null ? Text(pickedFile!.name) : const Text(""),
            if(widget.isSupervisor)
                Row(
                    children: [
                       Form(
                          key: formKey,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Supervisor Initial',
                              border: OutlineInputBorder(),
                              //alignLabelWithHint: true,
                            ),
                            controller: superVisorInitialInput,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter supervisor initial";
                              }
                              return null;
                            },
                          ),
                        ),

                      IconButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              superVisorInitial = superVisorInitialInput.text;
                              superVisorInitialInput.clear();
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_circle_right,
                          color: kPrimaryColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
      floatingActionButton: widget.isSupervisor
          ? Wrap(
              verticalDirection: VerticalDirection.up,
              direction: Axis.horizontal,
              alignment: WrapAlignment.spaceAround,
              spacing: 20,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                FloatingActionButton(
                  tooltip: "Select",
                  backgroundColor: kPrimaryColor,
                  onPressed: selectFile,
                  child: const Icon(Icons.select_all_outlined),
                ),
                FloatingActionButton(
                  tooltip: "Upload",
                  backgroundColor: kPrimaryColor,
                  onPressed: () {
                    if (pickedFile != null) {
                      uploadFile();
                    }
                  },
                  child: const Icon(Icons.upload),
                ),
              ],
            )
          : SizedBox(),
    );
  }
}
