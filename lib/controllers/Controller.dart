// import 'package:plannova/models/TaskModel.dart';
// import 'package:plannova/services/PlanGenerator.dart';
// import 'package:plannova/state/ActiveState.dart';
// import 'package:plannova/state/LazyState.dart';
// import 'package:plannova/state/UserState.dart';

// class PlanController {
//   final PlanService service = PlanService();

//   List<Task> tasks = [];

//   void generatePlan(UserState state, int hours) {
//     tasks = service.generate(state, hours);
//   }

//   void markDone(int index) {
//     tasks[index].isDone = true;
//   }
// void adaptPlan() {
//   int done = tasks.where((t) => t.isDone).length;
//   double rate = done / tasks.length;

//   if (rate < 0.5) {
//     tasks = PlanService().generate(LazyState(), 2);
//   } else {
//     tasks = PlanService().generate(ActiveState(), tasks.length);
//   }
// }}