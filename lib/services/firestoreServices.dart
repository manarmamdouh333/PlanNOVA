import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // 🔥 Save Initial Plan
  // =========================

  Future<String> savePlan({
    required String userId,
    required Map<String, String> days,
    required String energy,
    required List<Map<String, dynamic>> tasks,
  }) async {

    final docRef = await _firestore.collection('plans').add({
      "userId": userId,
      "days": days,
      "energy": energy,
      "tasks": tasks,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });

    // ربط آخر بلان باليوزر
    await _firestore.collection('users').doc(userId).set({
      "lastPlanId": docRef.id,
    }, SetOptions(merge: true));

    return docRef.id;
  }

  // =========================
  // 🤖 Save Generated Plan
  // =========================

  Future<void> saveGeneratedPlan({
    required String planId,
    required List<dynamic> generatedTasks,
  }) async {

    await _firestore
        .collection('plans')
        .doc(planId)
        .update({

      "generatedPlan": generatedTasks,

      "status": "completed",

      "generatedAt": FieldValue.serverTimestamp(),
    });
  }
}