
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;
class FirestoreServices {

  //get users data

  static getUser(uid) {
    return _firestore
        .collection('users')
        .where('user_id', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }
}
