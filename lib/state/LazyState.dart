import 'package:plannova/state/UserState.dart';
import 'package:plannova/strategies/LazyStrategy.dart';
import 'package:plannova/strategies/Strategy.dart';

class LazyState implements UserState {
  @override
  PlanStrategy getStrategy() => LazyStrategy();
}