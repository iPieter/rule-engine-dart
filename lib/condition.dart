import 'package:rule_engine/fact.dart';
import 'package:rule_engine/window.dart';

import 'nodes/node.dart';
import 'nodes/comparison_node.dart';

class Condition {
  Node _lhs;
  ComparisonNode _comparisonNode;
  Window window;
  Node _rhs;

  Condition(this._lhs, this._comparisonNode, this._rhs) {
    window = null;
  }
  Condition.fromWindow(Node lhs, Window window) {
    _lhs = lhs;
    this.window = window;
    this._rhs = null;
    this._comparisonNode = new ComparisonNode("in");
  }

  bool evaluateCondition(Map<String, dynamic> symbolTable, List<Fact> facts,
      Map<String, dynamic> clauseTable, Fact fact) {
    switch (_comparisonNode.operation) {
      case "<":
        num lvalue = num.parse(
                _lhs.getValue(symbolTable, facts, fact) ??
                    _lhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        num rvalue = num.parse(
                _rhs.getValue(symbolTable, facts, fact) ??
                    _rhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        return lvalue < rvalue;
      case ">":
        num lvalue = num.parse(
                _lhs.getValue(symbolTable, facts, fact) ??
                    _lhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        num rvalue = num.parse(
                _rhs.getValue(symbolTable, facts, fact) ??
                    _rhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        return lvalue > rvalue;
      case "<=":
        num lvalue = num.parse(
                _lhs.getValue(symbolTable, facts, fact) ??
                    _lhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        num rvalue = num.parse(
                _rhs.getValue(symbolTable, facts, fact) ??
                    _rhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        return lvalue <= rvalue;
      case ">=":
        num lvalue = num.parse(
                _lhs.getValue(symbolTable, facts, fact) ??
                    _lhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        num rvalue = num.parse(
                _rhs.getValue(symbolTable, facts, fact) ??
                    _rhs.getValue(clauseTable, facts, fact),
                (s) {}) ??
            0;
        return lvalue >= rvalue;
      case "==":
        return 0 ==
            (_lhs.getValue(symbolTable, facts, fact) ??
                    _lhs.getValue(clauseTable, facts, fact))
                .compareTo(_rhs.getValue(symbolTable, facts, fact) ??
                    _rhs.getValue(clauseTable, facts, fact));
      case "in":
        String lvalue = _lhs.getValue(symbolTable, facts, fact) ??
            _lhs.getValue(clauseTable, facts, fact);
        return window.contains(DateTime.parse(lvalue));

      default:
    }

    return false;
  }

  String toString() {
    return """{Condition: ${_lhs.getName()} ${_comparisonNode != null ? _comparisonNode.getName() : ""} ${_rhs != null ? _rhs.getName() : ""} ${window != null ? window.toString() : ""} }""";
  }
}
