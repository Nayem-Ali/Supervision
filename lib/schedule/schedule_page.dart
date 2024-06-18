import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supervision/schedule/view_appointments.dart';
import 'package:supervision/utility/bottom_navigation.dart';
import 'package:supervision/utility/constant_login.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'meeting.dart';
import 'meeting_data_source.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({Key? key}) : super(key: key);

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  TextEditingController superVisorInitialInput = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  TextEditingController dateInputController = TextEditingController();
  TextEditingController eventInputController = TextEditingController();
  TextEditingController durationInputController = TextEditingController();
  TextEditingController timeInputController = TextEditingController();

  CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");
  CollectionReference scheduleCollectionReference =
      FirebaseFirestore.instance.collection('schedule');

  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  final formKey = GlobalKey<FormState>();

  bool isSupervisor = false;
  String superVisorInitial = "";

  DateTime selectedDate = DateTime.now();
  int selectedHour = 0;
  int selectedMin = 0;
  final List<Meeting> meetings = [];

  @override
  void initState() {
    super.initState();
    checkSupervisor();
  }

  checkSupervisor() {
    DocumentReference documentReference =
        userCollectionReference.doc(currentUser);
    documentReference.get().then((userSnapshot) {
      setState(() {
        if (userSnapshot.exists) {
          isSupervisor = userSnapshot.get("isSupervisor");
          if (isSupervisor == true) {
            superVisorInitial = userSnapshot.get("initial");
            superVisorInitialInput.text = superVisorInitial;
            superVisorInitial = superVisorInitial.toUpperCase();
            getData();
          }
        }
      });
    });
  }

  /**
      @override
      void dispose() {
      // TODO: implement dispose
      super.dispose();
      eventInputController.dispose();
      dateInputController.dispose();
      durationInputController.dispose();
      timeInputController.dispose();
      }*/

  void setData() {
    final DateTime from =
        selectedDate.add(Duration(hours: selectedHour, minutes: selectedMin));
    final DateTime to =
        from.add(Duration(minutes: int.parse(durationInputController.text)));
    final String eventName =
        "${groupNameController.text} - ${eventInputController.text}";

    try {
      final DocumentReference documentReference = scheduleCollectionReference
          .doc(superVisorInitialInput.text.toUpperCase());

      documentReference.update({
        "meetings": FieldValue.arrayUnion([
          {
            'EventName': eventName,
            'Start': from,
            'End': to,
            "isComplete": false
          }
        ])
      }).whenComplete(() => showSnackBar(context, "Successfully update event"));
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message);
    }
  }

  void getData() {
    List<dynamic> schedule = [];
    DocumentReference documentReference =
        scheduleCollectionReference.doc(superVisorInitial);
    if (documentReference.id.isNotEmpty) {
      documentReference.get().then((value) {
        schedule = value.get("meetings");
        for (int i = 0; i < schedule.length; i++) {
          if (schedule[i]["isComplete"] != true) {
            String eventName = schedule[i]["EventName"];
            DateTime from = schedule[i]["Start"].toDate();
            DateTime to = schedule[i]["End"].toDate();
            meetings.add(
              Meeting(eventName, from, to, false, kPrimaryColor),
            );
          }
        }
        setState(() {
          meetings;
        });
      });
    }
  }

  _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Form(
            key: formKey,
            child: SimpleDialog(
              contentPadding: const EdgeInsets.all(10),
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Supervisor Initial',
                    alignLabelWithHint: true,
                  ),
                  readOnly: true,
                  controller: superVisorInitialInput,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Supervisor initial";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Group Name',
                    alignLabelWithHint: true,
                  ),
                  controller: groupNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Group Name";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Event Name',
                    alignLabelWithHint: true,
                  ),
                  controller: eventInputController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Event Name";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Select Date',
                  ),
                  controller: dateInputController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime(2050),
                    );

                    if (pickedDate != null &&
                        (pickedDate.day >= DateTime.now().day ||
                            pickedDate.month > DateTime.now().month)) {
                      dateInputController.text =
                          '${pickedDate.year}-${pickedDate.month}-${pickedDate.day}';
                      selectedDate = pickedDate;
                    } else {
                      showSnackBar(context, "Pick a valid date");
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Must pick a date";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Select Time',
                  ),
                  controller: timeInputController,
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      timeInputController.text = pickedTime.format(context);
                      selectedHour = pickedTime.hour;
                      selectedMin = pickedTime.minute;
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Must pick meeting time";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Duration in minutes',
                  ),
                  controller: durationInputController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter meeting duration";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            setData();
                            meetings.clear();
                            getData();
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add"),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"))
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: BackButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNavigation(),
                ));
          },
        ),
        actions: [
          isSupervisor
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAppointments(
                          meetings: meetings,
                          initial: superVisorInitial,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.schedule),
                )
              : SizedBox(),
        ],
        title: const Text("Calender"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: SfCalendar(
              todayHighlightColor: kPrimaryColor,
              allowAppointmentResize: true,
              initialSelectedDate: DateTime.now(),
              view: CalendarView.month,
              cellBorderColor: Colors.transparent,
              dataSource: MeetingDataSource(meetings),
              monthViewSettings: const MonthViewSettings(
                showAgenda: true,
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
              ),
            ),
          ),
          isSupervisor == false
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        child: Form(
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
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            superVisorInitial =
                                superVisorInitialInput.text.toUpperCase();
                            meetings.clear();
                            getData();
                            superVisorInitialInput.clear();
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.search,
                        color: kPrimaryColor,
                        size: 30,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
      floatingActionButton: isSupervisor
          ? FloatingActionButton(
              backgroundColor: kPrimaryColor,
              onPressed: _showDialog,
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
    );
  }
}
