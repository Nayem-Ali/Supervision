import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supervision/schedule/meeting.dart';
import 'package:supervision/schedule/schedule_page.dart';
import 'package:supervision/utility/constant_login.dart';

class ViewAppointments extends StatefulWidget {
  List<Meeting> meetings;
  String initial;

  ViewAppointments({Key? key, required this.meetings, required this.initial})
      : super(key: key);

  @override
  State<ViewAppointments> createState() => _ViewAppointmentsState();
}

class _ViewAppointmentsState extends State<ViewAppointments> {
  bool isComplete = false;

  List<dynamic> allMeeting = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllMeetings();
  }

  getAllMeetings() {
    for (int i = 0; i < widget.meetings.length; i++) {
      allMeeting.add({
        "EventName": widget.meetings[i].eventName,
        "Start": widget.meetings[i].from,
        'End': widget.meetings[i].to,
        "isComplete": false,
      });
    }
    setState(() {
      allMeeting;
    });
  }

  updateMeeting() {
    FirebaseFirestore.instance
        .collection("schedule")
        .doc(widget.initial)
        .update({"meetings": allMeeting});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Appointments"),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        leading: BackButton(
          onPressed: () {
            nextScreen(context, CalenderScreen());
          },
        ),
      ),
      body: ListView.builder(
        itemCount: allMeeting.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Checkbox(
                value: allMeeting[index]["isComplete"],
                onChanged: (value) {
                  setState(() {
                    allMeeting[index]["isComplete"] = value!;
                    updateMeeting();
                  });
                },
              ),
              title: Text(allMeeting[index]["EventName"]),
              subtitle: Text(
                  "From: ${allMeeting[index]["Start"]} \nTo: ${allMeeting[index]["End"]} "),
            ),
          );
        },
      ),
    );
  }
}
