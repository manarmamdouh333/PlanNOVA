import 'package:plannova/strategies/Strategy.dart';

abstract class UserState {
  PlanStrategy getStrategy();
}