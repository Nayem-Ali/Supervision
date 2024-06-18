import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supervision/pages/attendance/RecognitionScreen.dart';
import 'package:supervision/pages/attendance/attendance_view.dart';
import 'package:supervision/utility/constant_login.dart';

class AttendancePage extends StatefulWidget {
  String groupId;

  AttendancePage({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  TextEditingController dateInputController = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("groups");
  List<dynamic> attendanceList = [];
  final formKey = GlobalKey<FormState>();
  bool isSupervisor = false;
  List<String?> list = [];

  @override
  initState() {
    super.initState();
    getAllStudents();
  }

  getAllStudents() {
    DocumentReference documentReference =
        collectionReference.doc(widget.groupId);
    documentReference.get().then((groupSnapshot) {
      if (groupSnapshot.exists) {
        groupSnapshot.get("members").forEach((element) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(element)
              .get()
              .then((userSnapshot) {
            if (userSnapshot.get("isSupervisor") == false) {
              setState(() {
                attendanceList.add({
                  "student_id": userSnapshot.get("student_id"),
                  "name": userSnapshot.get("name"),
                  "isPresent": false,
                });
              });
            }
          });
        });
      }
    });
    setState(() {
      FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser)
          .get()
          .then((userSnapshot) {
        isSupervisor = userSnapshot.get("isSupervisor");
      });
    });
  }

  provideAttendance() {
    DocumentReference documentReference = collectionReference
        .doc(widget.groupId)
        .collection("attendance")
        .doc(dateInputController.text);
    documentReference.set({"attendance": attendanceList});
  }

  selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null) {
      if (pickedDate.month < 10 && pickedDate.day < 10) {
        dateInputController.text =
            '${pickedDate.year}-0${pickedDate.month}-0${pickedDate.day}';
      } else if (pickedDate.month < 10) {
        dateInputController.text =
            '${pickedDate.year}-0${pickedDate.month}-${pickedDate.day}';
      } else if (pickedDate.day < 10) {
        dateInputController.text =
            '${pickedDate.year}-${pickedDate.month}-0${pickedDate.day}';
      } else {
        dateInputController.text =
            '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Form(
              key: formKey,
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Select Date',
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.calendar_month),
                ),
                controller: dateInputController,
                readOnly: true,
                onTap: selectDate,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Select a date";
                  }
                  return null;
                },
              ),
            ),
          ),
          attendanceList.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      list = Get.arguments ?? [];
                      // print( list.contains(attendanceList[index]["student_id"]));
                      // print(attendanceList[index]["student_id"]);
                      print(list.isNotEmpty);
                      if (list.isNotEmpty) {
                        attendanceList[index]["isPresent"] =
                            list.contains(attendanceList[index]["student_id"]);
                      }
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: ListTile(
                          subtitle: Text(attendanceList[index]["name"]),
                          title: Text(attendanceList[index]["student_id"]),
                          trailing: Checkbox(
                            value: attendanceList[index]["isPresent"],
                            onChanged: (bool? value) {
                              if (dateInputController.text.isNotEmpty) {
                                //print("Alive");
                                setState(() {
                                  attendanceList[index]["isPresent"] = value;
                                });
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Expanded(child: Center(child: Text("No Student Found"))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isSupervisor == true)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          provideAttendance();
                          dateInputController.clear();
                          list.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor),
                      child: const Text("Submit"),
                    ),
                    const SizedBox(
                      width: 45,
                    ),
                    ElevatedButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecognitionScreen(
                              groupID: widget.groupId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor),
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  nextScreen(context, AttendanceView(groupId: widget.groupId));
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: const Text("View"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
