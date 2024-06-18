import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:supervision/utility/constant_login.dart';

import 'group_list.dart';

class GroupInfoPage extends StatefulWidget {
  String groupId;
  String groupName;

  GroupInfoPage({Key? key, required this.groupId, required this.groupName})
      : super(key: key);

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  final currentUser = FirebaseAuth.instance.currentUser!.uid;
  CollectionReference groupCollectionReference =
      FirebaseFirestore.instance.collection("groups");

  CollectionReference userCollectionReference =
      FirebaseFirestore.instance.collection("users");
  List<dynamic>? groupsList = [];
  List<dynamic>? membersList = [];
  List<String>? memberName = [];
  String admin = "";
  bool isSupervisor = false;

  @override
  initState() {
    super.initState();
    getAllMembers();
  }

  getAllMembers() {
    DocumentReference userDocumentReference =
        userCollectionReference.doc(currentUser);
    userDocumentReference.get().then((userSnapshot) {
      groupsList = userSnapshot.get("groups");
      isSupervisor = userSnapshot.get("isSupervisor");
    });
    DocumentReference documentReference =
        groupCollectionReference.doc(widget.groupId);
    documentReference.get().then((groupSnapshot) {
      if (groupSnapshot.exists) {
        membersList = groupSnapshot.get("members");
        groupSnapshot.get("members").forEach((userId) {
          userCollectionReference.doc(userId).get().then((userSnapshot) {
            setState(() {
              if (userId == groupSnapshot.get("admin")) {
                admin = userSnapshot.get("name");
              }
              memberName?.add(userSnapshot.get("name"));
            });
            //print(value.get("name"));
          });
        });
      }
    });
  }

  leaveGroup() {
    DocumentReference groupDocumentReference =
        groupCollectionReference.doc(widget.groupId);
    groupDocumentReference.update({"members": membersList});
    DocumentReference userDocumentReference =
        userCollectionReference.doc(currentUser);
    userDocumentReference.update({"groups": groupsList});
    nextScreen(context, const GroupListBar());
  }

  deleteGroup() {
    membersList?.forEach((element) {
      DocumentReference userDocumentReference =
          userCollectionReference.doc(element);
      userDocumentReference.update({
        "groups": FieldValue.arrayRemove([widget.groupId])
      });
    });

    groupCollectionReference.doc(widget.groupId).delete();
    nextScreen(context, const GroupListBar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          memberName != null
              ? Expanded(
                  child: ListView.builder(
                    itemCount: memberName?.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        color: Colors.grey.shade300,
                        child: ListTile(
                          trailing: isSupervisor
                              ? admin != memberName![index]
                                  ? IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.remove))
                                  : const SizedBox()
                              : const SizedBox(),
                          title: Text(memberName![index]),
                          subtitle: admin == memberName![index]
                              ? const Text("Admin")
                              : const Text("Member"),
                        ),
                      );
                    },
                  ),
                )
              : const Expanded(
                  child: Center(
                    child: Text("No members"),
                  ),
                ),
          isSupervisor == true
              ? ElevatedButton(
                  onPressed: deleteGroup,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  child: const Text("Delete Group"),
                )
              : ElevatedButton(
                  onPressed: () {
                    membersList?.remove(currentUser);
                    groupsList?.remove(widget.groupId);
                    leaveGroup();
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  child: const Text("Leave Group"),
                ),
        ],
      ),
    );
  }
}
