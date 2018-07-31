library rule_engine;

import 'package:rule_engine/fact.dart';
import 'package:rule_engine/rule.dart';

class RuleEngine {
  List<Rule> _rules;
  List<Fact> _facts;
  List<Function> _listeners;

  RuleEngine(this._rules) {
    _facts = new List();
    _listeners = new List();
  }

  void registerListener(Function f) {
    _listeners.add(f);
  }

  void insertFact(Fact fact) {
    for (Rule rule in _rules) {
      rule.evaluateRule(fact, _listeners);
    }

    _facts.add(fact);
  }
}
