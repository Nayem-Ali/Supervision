import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supervision/pages/initial_page.dart';
import 'package:supervision/utility/bottom_navigation.dart';
import 'package:supervision/utility/constant_login.dart';
import 'color_all.dart';


import 'group_register_page.dart';

class GroupListBar extends StatefulWidget {
  const GroupListBar({Key? key}) : super(key: key);

  @override
  State<GroupListBar> createState() => _GroupListBarState();
}

class _GroupListBarState extends State<GroupListBar> {
  TextEditingController textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? groupMap = {};

  List<dynamic> groupsList = [];
  final formKey = GlobalKey<FormState>();
  bool isSupervisor = false;

  @override
  initState() {
    super.initState();
    getAllGroups();
    checkSupervisor();
  }

  checkSupervisor() {
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

  getAllGroups() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("users").doc(currentUser);
    documentReference.get().then((userSnapshot) {
      if (userSnapshot.exists) {
        groupsList = userSnapshot.get("groups");
        for (var element in groupsList) {
          FirebaseFirestore.instance
              .collection("groups")
              .doc(element)
              .get()
              .then((groupSnapshot) {
            setState(() {
              groupMap?[groupSnapshot.get("groupName")] = element;
            });
          });
        }
      }
    });
  }

  Future<bool> searchGroup(groupId) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("groups");
    QuerySnapshot querySnapshot = await collectionReference.get();
    return querySnapshot.docs
        .map((e) {
          return e.id;
        })
        .toList()
        .contains(groupId);
  }

  joinGroup() {
    DocumentReference usersDocumentReference =
        FirebaseFirestore.instance.collection("users").doc(currentUser);
    usersDocumentReference.update({
      "groups": FieldValue.arrayUnion([textController.text])
    });
    DocumentReference groupDocumentReference = FirebaseFirestore.instance
        .collection("groups")
        .doc(textController.text);
    groupDocumentReference.update({
      "members": FieldValue.arrayUnion([currentUser])
    });
    setState(() {
      getAllGroups();
    });
    textController.clear();
    Navigator.pop(context);
  }

  void _showSearchDialog(title, content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (groupsList.contains(textController.text) == false)
              TextButton(
                onPressed: () {
                  setState(() {
                    joinGroup();
                  });
                },
                child: const Text("Join Group"),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;

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
        title: const Text("Group"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 2,),
          Row(
            children: [
              const SizedBox(width: 5,),
              Expanded(
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Search..",
                     // border: InputBorder.none,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Group ID";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (groupsList.contains(textController.text)) {
                      _showSearchDialog(
                          "Dear User", "You have already joined this group");
                    } else if (await searchGroup(textController.text)) {
                      _showSearchDialog("Group Found",
                          "Click Join Group to join as a group member");
                    } else {
                      _showSearchDialog(
                          "Group Not Found", "Try with correct group id");
                    }
                  }
                },
                icon: const Icon(
                  Icons.search,
                  color: kPrimaryColor,
                  size: 27,
                ),
              ),
            ],
          ),
          groupMap!.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: groupMap?.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          nextScreen(
                            context,
                            InitialPage(
                              groupName:
                              groupMap?.keys.elementAt(index) ?? "",
                              groupId: groupMap?.values.elementAt(index),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            trailing: IconButton(
                              onPressed: () {
                                Share.share(
                                  groupMap?.values.elementAt(index),
                                );
                              },
                              icon: const Icon(Icons.share),
                            ),
                            title: Text(groupMap?.keys.elementAt(index) ?? ""),
                            subtitle: Text(groupMap?.values.elementAt(index)),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Expanded(
                  child: Center(
                    child: Text("No group found.."),
                  ),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nextScreen(context, const GroupRegisterPage());
        },
        backgroundColor: kAppBarColor,
        child: const Icon(
          Icons.group,
          size: 30,
        ),
      ),
      //bottomNavigationBar: const BottomNav(),
    );
  }
}
