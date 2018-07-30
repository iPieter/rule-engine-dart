library rule_engine;

import 'package:rule_engine/fact.dart';
import 'package:rule_engine/rule.dart';

class RuleEngine {
  List<Rule> _rules;

  RuleEngine(this._rules);

  void insertFact(Fact fact) {
    for (Rule rule in _rules) {
      rule.evaluateRule(fact);
    }
  }
}
