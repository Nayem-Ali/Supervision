import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supervision/utility/constant_login.dart';

class TaskPage extends StatefulWidget {
  String groupId;

  TaskPage({super.key, required this.groupId});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<dynamic>? taskList;
  final taskController = TextEditingController();
  final dateInputController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  CollectionReference collectionReference =
  FirebaseFirestore.instance.collection("groups");

  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  bool isSupervisor = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTasks();
  }

  getAllTasks() {
    DocumentReference documentReference =
    collectionReference.doc(widget.groupId);
    documentReference.get().then((value) {
      setState(() {
        taskList = value.get("tasks");
      });
      for (int i = 0; i < taskList!.length; i++) {
        DateTime today = DateTime.now();
        DateTime deadline = taskList?[i]["deadline"].toDate();
        String status = taskList?[i]["isComplete"];

        if (status == "In Progress") {
          //print(today.isAfter(deadline));
          print(deadline.difference(today).inDays);
          if (deadline.difference(today).inDays < 0) {
            setState(() {
              taskList?[i]["isComplete"] = "Incomplete";

            });
          }
        }
      }
    });
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser)
        .get()
        .then((value) {
      setState(() {
        isSupervisor = value.get("isSupervisor");
      });
    });
  }

  addTask() {
    DocumentReference documentReference =
    collectionReference.doc(widget.groupId);
    documentReference.update({
      "tasks": FieldValue.arrayUnion([
        {
          "taskName": taskController.text,
          "isComplete": "In Progress",
          "deadline": selectedDate
        }
      ])
    });
    setState(() {
      getAllTasks();
      taskController.clear();
    });
  }

  updateTaskStatus() {
    DocumentReference documentReference =
    collectionReference.doc(widget.groupId);

    setState(() {
      documentReference.update({"tasks": taskList});
    });
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
                    hintText: 'Task Name',
                    alignLabelWithHint: true,
                  ),
                  controller: taskController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Task Name";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Deadline',
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
                        (pickedDate.day >= DateTime
                            .now()
                            .day ||
                            pickedDate.month > DateTime
                                .now()
                                .month)) {
                      dateInputController.text =
                      '${pickedDate.year}-${pickedDate.month}-${pickedDate
                          .day}';
                      selectedDate = pickedDate;
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Must pick a valid date";
                    }
                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          addTask();
                          setState(() {});
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
      body: Column(
        children: [
          taskList != null
              ? Expanded(
            child: taskList!.isNotEmpty
                ? ListView.builder(
              itemCount: taskList?.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: taskList?[index]["isComplete"] !=
                        "Incomplete"
                        ? Checkbox(
                      value: taskList?[index]["isComplete"] ==
                          "In Progress"
                          ? false
                          : true,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            taskList?[index]["isComplete"] =
                            "Completed";
                          } else {
                            taskList?[index]["isComplete"] =
                            "In Progress";
                          }
                          updateTaskStatus();
                        });
                      },
                    )
                        : const Icon(
                      Icons.close,
                      size: 45,
                      color: Colors.red,
                    ),
                    title: Text(
                      taskList?[index]["taskName"],
                      style: kTextStyle,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Deadline: ${taskList?[index]["deadline"]
                                .toDate()
                                .toString()
                                .substring(0, 10)}'),
                        Text(
                            'Status: ${taskList?[index]["isComplete"]}')
                      ],
                    ),
                    trailing: isSupervisor
                        ? IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        taskList?.remove(
                            taskList?.elementAt(index));
                        updateTaskStatus();
                      },
                    )
                        : const SizedBox(),
                  ),
                );
              },
            )
                : const Center(
              child: Text("No task assigned"),
            ),
          )
              : const Expanded(
            child: Center(
                child: CircularProgressIndicator(color: kPrimaryColor)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
