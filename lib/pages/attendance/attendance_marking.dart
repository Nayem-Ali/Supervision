import 'package:flutter/material.dart';
import 'package:supervision/utility/constant_login.dart';


import '../../utility/reusable_button.dart';

class AttendanceMarkingPage extends StatefulWidget {
  List<dynamic> attendance;

  AttendanceMarkingPage({Key? key, required this.attendance}) : super(key: key);

  @override
  State<AttendanceMarkingPage> createState() => _AttendanceMarkingPageState();
}

class _AttendanceMarkingPageState extends State<AttendanceMarkingPage> {
  Map<dynamic, int> attendanceCount = {};
  TextEditingController markController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  int mark = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calculateAttendance();
  }

  calculateAttendance() {
    setState(() {
      for (int i = 0; i < widget.attendance.length; i++) {
        attendanceCount[widget.attendance[i]["student_id"]] = 0;
      }
      for (int i = 0; i < widget.attendance.length; i++) {
        if (widget.attendance[i]["isPresent"] == true) {
          attendanceCount[widget.attendance[i]["student_id"]] =
              (attendanceCount[widget.attendance[i]["student_id"]]! + 1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Attendance Marks"),
          backgroundColor: kPrimaryColor,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      attendanceCount.entries
                          .map((entry) => 'Student ID: ${entry.key}')
                          .join("\n\n"),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      attendanceCount.entries
                          .map((entry) =>
                              ' = ${(mark * entry.value / (widget.attendance.length / attendanceCount.length)).toStringAsFixed(2)} marks')
                          .join("\n\n"),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: markController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter any number";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Button( 
                  buttonName: "Calculate",
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          mark = int.parse(markController.text);
                        });
                      }
                    },
                ),
              )
            ],
          ),
        )

        ///myMap.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n')
        );
  }
}
