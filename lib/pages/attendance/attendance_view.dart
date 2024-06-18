import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supervision/pages/attendance/attendance_marking.dart';
import 'package:supervision/utility/constant_login.dart';

class AttendanceView extends StatefulWidget {
  String groupId;

  AttendanceView({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  CollectionReference collectionReference =
  FirebaseFirestore.instance.collection("groups");
  final fireStore = FirebaseFirestore.instance;
  List<dynamic> takenAttendance = [];
  List<dynamic> dates = [];
  late int numberOfStudent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAttendance();
  }

  getAttendance() {
    fireStore
        .collection("groups")
        .doc(widget.groupId)
        .collection('attendance')
        .get()
        .then(
          (value) {
        for (int i = 0; i < value.docs.length; i++) {
          dates.add(value.docs[i].id);
          List<dynamic> temp = value.docs[i].get("attendance");
          numberOfStudent = temp.length;
          for (int j = 0; j < temp.length; j++) {
            setState(() {
              takenAttendance.add(temp[j]);
            });
          }
        }

        print(takenAttendance);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Attendance List"),
      ),
      body: ListView.builder(
        itemCount: takenAttendance.length,
        itemBuilder: (context, index) {
        
          int dateIndex = index ~/ numberOfStudent;
          return Column(
            children: [
              if (index % numberOfStudent == 0)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "Date: ${dates[dateIndex]}",
                    style: kTextStyle,
                  ),
                ),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Text(
                          "${takenAttendance[index]["name"]}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(

                          ),
                        ),
                      ),
                      TableCell(
                        child: Text(
                          "${takenAttendance[index]["student_id"]}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(

                          ),
                        ),
                      ),
                      TableCell(
                        child: takenAttendance[index]["isPresent"] ? const Text(
                          "P",
                          textAlign: TextAlign.center,

                        ):const Text(
                          "A",
                          textAlign: TextAlign.center,

                        )
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nextScreen(
              context,
              AttendanceMarkingPage(
                attendance: takenAttendance,
              ));
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.auto_graph_outlined),
      ),
    );
  }
}
