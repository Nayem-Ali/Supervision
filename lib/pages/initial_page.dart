import 'package:flutter/material.dart';
import 'package:supervision/pages/attendance/attendence_page.dart';
import 'package:supervision/pages/files/files_page.dart';
import 'package:supervision/pages/tasks/task_view.dart';
import 'package:supervision/screens/group_info.dart';
import 'package:supervision/screens/group_list.dart';
import 'package:supervision/utility/constant_login.dart';


import 'chats/chat_page.dart';

class InitialPage extends StatefulWidget {
  String groupId;
  String groupName;

  InitialPage({Key? key, required this.groupId, required this.groupName}) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
          backgroundColor: kPrimaryColor,
          centerTitle: true,
          leading: BackButton(
            onPressed: () {
              nextScreen(context, const GroupListBar());
            },
          ),
          actions: [
            IconButton(
                onPressed: () {
                  nextScreen(context, GroupInfoPage(groupId: widget.groupId,groupName: widget.groupName,));
                },
                icon: const Icon(Icons.info))
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.school_outlined)),
              Tab(icon: Icon(Icons.chat)),
              Tab(icon: Icon(Icons.file_copy_sharp)),
              Tab(icon: Icon(Icons.task)),

            ],
          ),

        ),
        body: TabBarView(
          children: [
            AttendancePage(groupId: widget.groupId),
            ChatPage(groupId: widget.groupId),
            FilesPage(groupId: widget.groupId),
            TaskPage(groupId: widget.groupId),

          ],
        ),
      ),
    );
  }
}
