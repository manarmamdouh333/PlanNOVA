import 'package:plannova/models/TaskModel.dart';
import 'package:plannova/strategies/Strategy.dart';

class LazyStrategy implements PlanStrategy {
  @override
  List<Task> generate(int hours) {
    return [
      Task("Easy Study", 1),
      Task("Light Revision", 1),
    ];
  }
}