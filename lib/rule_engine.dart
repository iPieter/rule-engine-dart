library rule_engine;

import 'package:rule_engine/fact.dart';
import 'package:rule_engine/rule.dart';

class RuleEngine {
  List<Rule> _rules;
  List<Fact> _facts;

  RuleEngine(this._rules) {
    _facts = new List();
  }

  void insertFact(Fact fact) {
    for (Rule rule in _rules) {
      print(rule.evaluateRule(fact, _facts));
    }

    _facts.add(fact);
  }
}
