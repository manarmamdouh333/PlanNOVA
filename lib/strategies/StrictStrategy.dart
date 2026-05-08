import 'package:plannova/models/TaskModel.dart';
import 'package:plannova/strategies/Strategy.dart';

class StrictStrategy implements PlanStrategy {
  @override
  List<Task> generate(int hours) {
    return List.generate(hours, (i) => Task("Hard Task ${i+1}", 1));
  }
}