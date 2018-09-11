import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/src/fact.dart';
import 'package:rule_engine/src/nodes/arithmetic_node.dart';
import 'package:rule_engine/src/window.dart';

import 'nodes/node.dart';
import 'nodes/comparison_node.dart';

class Condition {
  Node _lhs;
  ComparisonNode _comparisonNode;
  Window window;
  Node _rhs;

  Condition(this._lhs, this._comparisonNode, this._rhs) {
    window = null;
    _optimizeArithmeticNodes();
  }
  Condition.fromWindow(Node lhs, Window window) {
    _lhs = lhs;
    this.window = window;
    this._rhs = null;
    this._comparisonNode = new ComparisonNode("in");
    _optimizeArithmeticNodes();
  }

  void _optimizeArithmeticNodes() {
    bool finalized = false;

    while (!finalized && _lhs is ArithmeticNode) {
      var n = _lhs as ArithmeticNode;

      if (n.operations.length == 0 && n.otherNodes.length == 0) {
        _lhs = n.startNode;
      } else {
        finalized = true;
      }
    }

    finalized = false;

    while (!finalized && _rhs is ArithmeticNode) {
      var n = _rhs as ArithmeticNode;

      if (n.operations.length == 0 && n.otherNodes.length == 0) {
        _rhs = n.startNode;
      } else {
        finalized = true;
      }
    }
  }

  bool evaluateCondition(Map<String, dynamic> symbolTable, List<Fact> facts,
      Map<String, dynamic> clauseTable, Fact fact) {
    switch (_comparisonNode.operation) {
      case "<":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact)) ??
            0;
        num rvalue = num.tryParse(_rhs.getValue(symbolTable, facts, fact) ??
                _rhs.getValue(clauseTable, facts, fact)) ??
            0;
        return lvalue < rvalue;
      case ">":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact)) ??
            0;
        num rvalue = num.tryParse(_rhs.getValue(symbolTable, facts, fact) ??
                _rhs.getValue(clauseTable, facts, fact)) ??
            0;
        return lvalue > rvalue;
      case "<=":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact)) ??
            0;
        num rvalue = num.tryParse(_rhs.getValue(symbolTable, facts, fact) ??
                _rhs.getValue(clauseTable, facts, fact)) ??
            0;
        return lvalue <= rvalue;
      case ">=":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact)) ??
            0;
        num rvalue = num.tryParse(_rhs.getValue(symbolTable, facts, fact) ??
                _rhs.getValue(clauseTable, facts, fact)) ??
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

  bool hasStaticSide() {
    return _lhs is LiteralNode ||
        _lhs is AttributeNode ||
        _rhs is LiteralNode ||
        _rhs is AttributeNode;
  }

  /// Returns the static side of a [Condition], if there is one. The
  /// function prefers [AttributeNode]s above [LiteralNode]s.
  ///
  /// If no static side is found, null is returned.
  String obtainStaticSide() {
    if (_lhs is AttributeNode)
      return _lhs.getName();
    else if (_rhs is LiteralNode || _rhs is AttributeNode)
      return _rhs.getName();
    else if (_lhs is LiteralNode) return _lhs.getName();
    return null;
  }
}
