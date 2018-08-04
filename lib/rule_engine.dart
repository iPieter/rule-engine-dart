library rule_engine;

import 'package:rule_engine/fact.dart';
import 'package:rule_engine/lexer.dart';
import 'package:rule_engine/parser.dart';
import 'package:rule_engine/rule.dart';

class RuleEngine {
  List<Rule> _rules;
  List<Function> _listeners;

  /// Create a new [RuleEngine] object and automatically parse the [code]
  /// given as an attribute. This string can consist of multiple rules.
  ///
  /// Parsing errrors are printed to stdout.
  RuleEngine(String code) {
    _listeners = new List();

    Lexer lexer = new Lexer(code);
    var tokens = lexer.getTokenList();
    //tokens.forEach((e) => print(e) );

    Parser parser = new Parser(tokens);

    this._rules = parser.buildTree();
  }

  void registerListener(Function f) {
    _listeners.add(f);
  }

  void insertFact(Fact fact) {
    for (Rule rule in _rules) {
      rule.evaluateRule(fact, _listeners);
    }
  }
}
