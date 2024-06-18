import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:supervision/screens/color_all.dart';
import 'package:supervision/utility/constant_login.dart';

class ChatPage extends StatefulWidget {
  final String groupId;

  ChatPage({Key? key, required this.groupId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _message = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  String userName = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }
  refresh (){
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  getUser() {
    DocumentReference documentReference = collectionReference.doc(currentUser);
    documentReference.get().then((value) {
      setState(() {
        userName = value.get("name");
      });
    });
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": userName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };
      _message.clear();
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 1.33,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(

                stream: _firestore
                    .collection('groups')
                    .doc(widget.groupId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  //refresh();
                  if (snapshot.hasData) {
                    //refresh();
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        //reverse: true,
                        itemCount: snapshot.data!.docs.length+1,
                        itemBuilder: (context, index) {

                          if (index == snapshot.data!.docs.length) {
                            return Container(
                              height: 80,
                            );
                          }

                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTile(size, chatMap);

                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            //const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  //height: size.height,
                  height: size.height / 13,
                  width: size.width / 1.3,
                  child: TextFormField(
                    maxLines: null,
                    controller: _message,
                    decoration: InputDecoration(
                        hintText: "Send Message..",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        )),
                  ),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: kPrimaryColor,
                      size: 30,
                    ),
                    onPressed: () {
                      refresh();
                      onSendMessage();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    var t = chatMap['time'] == null ? DateTime.now() : chatMap['time'].toDate();
    var time = intl.DateFormat("h:mma").format(t);
    return Builder(builder: (_) {
      //refresh();
      //if (chatMap['type'] == "text") {
      return Column(
        children: [
          Container(
            width: size.width,
            alignment: chatMap['sendBy'] == userName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              //width: size.width/1.5,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                color: chatMap['sendBy'] == userName
                    ? kAppBarColor
                    : Colors.blueGrey,
              ),
              child: Column(
                crossAxisAlignment: chatMap['sendBy'] == userName
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  SelectableText(
                    chatMap['message'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      /*} else {
        return const SizedBox();
      }*/
    });
  }
}

