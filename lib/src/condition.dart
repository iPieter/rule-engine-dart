import 'package:rule_engine/src/fact.dart';
import 'package:rule_engine/src/window.dart';

import 'nodes/node.dart';
import 'nodes/comparison_node.dart';

class Condition {
  final Node _lhs;
  final ComparisonNode _comparisonNode;
  final Window? window;
  final Node? _rhs;

  const Condition(Node lhs, ComparisonNode comparisonNode, Node rhs)
      : _lhs = lhs,
        _comparisonNode = comparisonNode,
        window = null,
        _rhs = rhs;

  const Condition.fromWindow(Node lhs, Window window)
      : _lhs = lhs,
        _comparisonNode = const ComparisonNode('in'),
        window = window,
        _rhs = null;

  bool evaluateCondition(Map<String, dynamic> symbolTable, List<Fact> facts,
      Map<String, dynamic> clauseTable, Fact fact) {
    switch (_comparisonNode.operation) {
      case "<":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        num rvalue = num.tryParse(_rhs?.getValue(symbolTable, facts, fact) ??
                _rhs?.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        return lvalue < rvalue;
      case ">":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        num rvalue = num.tryParse(_rhs?.getValue(symbolTable, facts, fact) ??
                _rhs?.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        return lvalue > rvalue;
      case "<=":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        num rvalue = num.tryParse(_rhs?.getValue(symbolTable, facts, fact) ??
                _rhs?.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        return lvalue <= rvalue;
      case ">=":
        num lvalue = num.tryParse(_lhs.getValue(symbolTable, facts, fact) ??
                _lhs.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        num rvalue = num.tryParse(_rhs?.getValue(symbolTable, facts, fact) ??
                _rhs?.getValue(clauseTable, facts, fact) ??
                '') ??
            0;
        return lvalue >= rvalue;
      case "==":
        return 0 ==
            (_lhs.getValue(symbolTable, facts, fact) ??
                    _lhs.getValue(clauseTable, facts, fact))
                ?.compareTo(_rhs?.getValue(symbolTable, facts, fact) ??
                    _rhs?.getValue(clauseTable, facts, fact) ??
                    '');
      case "in":
        final lvalue = _lhs.getValue(symbolTable, facts, fact) ??
            _lhs.getValue(clauseTable, facts, fact);
        if (lvalue == null) return false;
        return window?.contains(DateTime.parse(lvalue)) ?? false;

      default:
    }

    return false;
  }

  String toString() {
    return """{Condition: ${_lhs.getName()} ${_comparisonNode.getName()} ${_rhs?.getName() ?? ""} ${window?.toString() ?? ""} }""";
  }
}
