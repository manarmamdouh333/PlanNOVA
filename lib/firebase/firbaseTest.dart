import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testWrite() async {
  print("🧪 testWrite STARTED");

  await FirebaseFirestore.instance
      .collection("users")
      .doc("testUser")
      .set({
    "energyType": "morning",
    "freeHours": {
      "monday": 5,
      "tuesday": 3,
    }
  });

  print("🔥 DATA WRITTEN TO FIRESTORE");
}