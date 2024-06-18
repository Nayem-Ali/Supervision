
import 'package:cloud_firestore/cloud_firestore.dart';

import '../ML/Recognition.dart';

class DBService {

  final _fireStore = FirebaseFirestore.instance;
  addDatabase(String key, Recognition recognition, String uid) async{
    try{


      await _fireStore.collection("users").doc(uid).collection("face").doc(key).set(
          {
            "id": recognition.name,
            "location": recognition.location.toString(),
            "distance": recognition.distance,
            "embeddings": recognition.embeddings
          }
      );


    }
    on FirebaseException catch (e){
      print("Message: ${ e.message}");
    }
  }


}