import 'package:plannova/models/TaskModel.dart';

abstract class PlanStrategy {
  List<Task> generate(int hours);
}