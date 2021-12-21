library rule_engine;

import 'package:rule_engine/src/fact.dart';
import 'package:rule_engine/src/lexer.dart';
import 'package:rule_engine/src/parser.dart';
import 'package:rule_engine/src/rule.dart';

export 'package:rule_engine/src/lexer.dart';
export 'package:rule_engine/src/fact.dart';
export 'package:rule_engine/src/parser.dart';
export 'package:rule_engine/src/rule.dart';
export 'package:rule_engine/src/token.dart';
export 'package:rule_engine/src/assignment.dart';
export 'package:rule_engine/src/clause.dart';
export 'package:rule_engine/src/condition.dart';
export 'package:rule_engine/src/consequence.dart';
export 'package:rule_engine/src/fact_store.dart';
export 'package:rule_engine/src/nodes/aggregate_node.dart';
export 'package:rule_engine/src/nodes/attribute_node.dart';
export 'package:rule_engine/src/nodes/comparison_node.dart';
export 'package:rule_engine/src/nodes/literal_node.dart';
export 'package:rule_engine/src/nodes/node.dart';
export 'package:rule_engine/src/nodes/symbol_node.dart';

class RuleEngine {
  final List<Function> _listeners = [];
  late List<Rule> _rules;

  /// Create a new [RuleEngine] object and automatically parse the [code]
  /// given as an attribute. This string can consist of multiple rules.
  ///
  /// Parsing errors are printed to stdout.
  RuleEngine(String code) {
    final lexer = Lexer(code);
    final tokens = lexer.getTokenList();
    final parser = Parser(tokens, code);

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
