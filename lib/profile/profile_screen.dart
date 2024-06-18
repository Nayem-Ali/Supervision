import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supervision/profile/edit_profile_screen.dart';
import 'package:supervision/profile/profile_controller.dart';
import 'package:supervision/screens/color_all.dart';
import 'package:velocity_x/velocity_x.dart';
import '../log_in/sign_in.dart';
import '../utility/bottom_navigation.dart';
import '../utility/constant_login.dart';
import 'firestore_services.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ProfileController());
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
        title: const Text("Profile"),
      ),
      //backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirestoreServices.getUser(_auth.currentUser!.uid),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              );
            } else {
              var data = snapshot.data!.docs[0];

              return Column(
                children: [
                  //edit profile button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.edit, color: Colors.black))
                        .onTap(() {
                      //controller.nameController.text = data['name'];
                      Get.to(() => EditProfileScreen(data: data));
                    }),
                  ),

                  //user details section

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        data['imageUrl'] == ''
                            ? Image.asset('images/profile.jpg',
                                height: 130,
                                width: 130, fit: BoxFit.fill)
                            : Image.network(data['imageUrl'],
                                    height: 130,
                                    width: 130, fit: BoxFit.fill)
                                .box
                                .roundedFull
                                .clip(Clip.antiAlias)
                                .make(),
                        //10.widthBox,
                        30.heightBox,
                        Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueGrey,

                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.account_box,
                                            color: Colors.white,
                                          ),
                                          10.widthBox,
                                          "${data['name']}"
                                              .text
                                              .minFontSize(18)
                                              .white
                                              .fontWeight(FontWeight.w500)
                                              .make(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueGrey,

                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.email,
                                            color: Colors.white,
                                          ),
                                          10.widthBox,
                                          "${data['email']}"
                                              .text
                                              .minFontSize(18)
                                              .white
                                              .fontWeight(FontWeight.w500)
                                              .make(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueGrey,

                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.book,
                                            color: Colors.white,
                                          ),
                                          10.widthBox,
                                          data['isSupervisor']
                                              ? "${data['initial']}"
                                                  .text
                                                  .minFontSize(18)
                                                  .white
                                                  .fontWeight(FontWeight.w500)
                                                  .make()
                                              : "${data['student_id']}"
                                                  .text
                                                  .minFontSize(18)
                                                  .white
                                                  .fontWeight(FontWeight.w500)
                                                  .make(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: const BoxDecoration(
                                    color: Colors.blueGrey,

                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            color: Colors.white,
                                          ),
                                          10.widthBox,
                                          "${data['phone']}"
                                              .text
                                              .minFontSize(18)
                                              .white
                                              .fontWeight(FontWeight.w500)
                                              .make(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                //"${data['email']}".text.black.make(),
                              ],
                            )
                          ],
                        ),

                      ],
                    ),
                  ),
                  20.heightBox,
                  Row(
                    children: [
                      InkWell(
                        onTap: () async{
                          FirebaseAuth auth = FirebaseAuth.instance;
                          await auth.signOut();
                          replaceScreen(context, SigninPage());
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height/17,
                          width: MediaQuery.of(context).size.width,
                          //padding:
                          //const EdgeInsets.symmetric(horizontal: 157, vertical: 10),
                          //margin: const EdgeInsets.only(bottom: 20),
                          decoration: const BoxDecoration(
                            color: Colors.blueGrey,
                            /*borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20),
                                      ),*/
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 20,),
                                  Icon(Icons.logout),
                                  SizedBox(width: 10,),
                                  Text("Log out"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                  //BUTTONS
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
