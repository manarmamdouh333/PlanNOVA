import 'package:plannova/state/UserState.dart';
import 'package:plannova/strategies/Strategy.dart';
import 'package:plannova/strategies/StrictStrategy.dart';

class ActiveState implements UserState {
  @override
  PlanStrategy getStrategy() => StrictStrategy();
}