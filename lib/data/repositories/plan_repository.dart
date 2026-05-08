// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:plannova/data/models/task_entity.dart';
// import 'package:plannova/services/firestoreServices.dart';

// class PlanRepository {
//   final FirestorePlanService _service;

//   PlanRepository(this._service);

//   Future<String> ensureUserPlan(String userId) async {
//     final existingPlan = await _service.findPlanByUser(userId);
//     if (existingPlan != null) {
//       return existingPlan.id;
//     }

//     return _service.createPlan(userId);
//   }

//   Stream<List<TaskEntity>> watchTasks(String userId) {
//     return _service.watchPlan(userId).map((doc) {
//       if (doc == null || !doc.exists) return [];
//       final rawTasks = List<Map<String, dynamic>>.from(
//         (doc.data()?['tasks'] as List<dynamic>? ?? []).map(
//           (item) => Map<String, dynamic>.from(item as Map<String, dynamic>),
//         ),
//       );
//       return rawTasks.map(TaskEntity.fromJson).toList();
//     });
//   }

//   Future<void> addTask(String userId, TaskEntity task) async {
//     final planDoc = await _service.findPlanByUser(userId);
//     final planId = planDoc?.id ?? await _service.createPlan(userId);

//     final currentTasks = planDoc?.data()?['tasks'] as List<dynamic>? ?? [];
//     final updatedTasks = List<Map<String, dynamic>>.from(currentTasks
//         .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>)));

//     updatedTasks.add(task.toJson());
//     await _service.updateTasks(planId, updatedTasks);
//   }

//   Future<void> updateTask(
//     String userId,
//     TaskEntity updatedTask,
//     TaskEntity originalTask,
//   ) async {
//     final planDoc = await _service.findPlanByUser(userId);
//     if (planDoc == null) return;

//     final planId = planDoc.id;
//     final currentTasks = planDoc.data()?['tasks'] as List<dynamic>? ?? [];

//     final updatedTasks = currentTasks.map((rawItem) {
//       final item = Map<String, dynamic>.from(rawItem as Map<String, dynamic>);
//       final existingTask = TaskEntity.fromJson(item);
//       if (existingTask.matches(originalTask)) {
//         return updatedTask.toJson();
//       }
//       return item;
//     }).toList();

//     await _service.updateTasks(planId, updatedTasks);
//   }
// }

// class FirestorePlanService {
// }
