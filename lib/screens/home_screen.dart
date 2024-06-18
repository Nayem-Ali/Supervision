import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supervision/utility/constant_login.dart';
import 'package:supervision/utility/notifications.dart';
import '../schedule/schedule_page.dart';
import 'color_all.dart';
import 'group_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> quotes = [
    "“Everything you can imagine is real.”― Pablo Picasso",
    "“Whatever you are, be a good one.” ― Abraham Lincoln",
    "“If something is important enough, even if the odds are stacked against you, you should still do it.” —Elon Musk",
    "The secret of getting ahead is getting started. - Mark Twain",
    "Nothing in the world can take the place of Persistence. Talent will not; nothing is more common than unsuccessful men with talent. Genius will not; unrewarded genius is almost a proverb. Education will not; the world is full of educated derelicts. The slogan 'Press On' has solved and always will solve the problems of the human race. —Calvin Coolidge"
  ];
  final user = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot? userData;

  @override
  initState() {
    super.initState();
    getUserInfo();
  }

  getUserInfo() async {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("users").doc(user);
    documentReference.get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          userData = snapshot;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //this gonna give us total height and width of our device
    var hijri = HijriCalendar.now();

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              // Here the height of the container is 33% of our total height
              height: MediaQuery.of(context).size.height * .37,
              decoration: const BoxDecoration(
                color: kAppBarColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(2, 56, 63, 0.692),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: userData != null
                  ? Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hello,\n${userData!.get("name")}",
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 52,
                        width: 52,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 2, 53, 62),
                          shape: BoxShape.circle,
                        ),
                        //child: Expanded(
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: () {
                            // Here we write a code for Notifications
                            nextScreen(context, const Notifications());
                          },
                        ),
                        //),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMM yyyy')
                            .format(DateTime.now()),

                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 19,
                          color: Colors.white,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hijri.hDay.toString(),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            hijri.longMonthName.toString(),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            hijri.hYear.toString(),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            " AH",
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          Share.share("Super Vision\n\n"
                              "English Date: ${DateFormat('EEEE, dd MMM yyyy')
                              .format(DateTime.now())}\n"
                              "Hijri Date: ${hijri.hDay.toString()} ${hijri
                              .longMonthName.toString()} ${hijri.hYear
                              .toString()} AH");
                        },
                      ),

                    ],
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height/40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      forHome(
                        Text("Group", style: kTextStyle),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const GroupListBar()),
                          );
                        },
                        const Image(
                            height: 100,
                            width: 110,
                            image: AssetImage('images/Group.png')),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width/16,
                      ),
                      forHome(
                        Text("Schedule", style: kTextStyle),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              (const CalenderScreen()),
                            ),
                          );
                        },
                        const Image(
                            height: 100,
                            width: 100,
                            image: AssetImage('images/Schedule.png')),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    padding: const EdgeInsets.all(10),
                    height: 140,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(3, 15),
                          blurRadius: 6,
                          spreadRadius: -5,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    child: Text(
                      quotes[Random().nextInt(3)],
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  )
                ],
              )
                  : const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget forHome(Widget title, VoidCallback onTap, Widget image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height / 5.7,
        width: MediaQuery
            .of(context)
            .size
            .width / 2.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              offset: Offset(3, 20),
              blurRadius: 6,
              spreadRadius: -5,
              color: Colors.black,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                image,
                title,
              ],
            ),
          ),
        ),
      ),
    );
  }
}