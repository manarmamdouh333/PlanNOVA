import 'package:plannova/observer/observerPattern.dart';

class ProgressTracker implements Observer {
  @override
  void update() {
    print("Progress Updated");
  }
}