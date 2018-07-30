import 'package:rule_engine/fact.dart';

import 'nodes/node.dart';
import 'nodes/comparison_node.dart';

class Condition {
  Node _lhs;
  ComparisonNode _comparisonNode;
  Node _rhs;

  Condition(this._lhs, this._comparisonNode, this._rhs);

  bool evaluateCondition(Map<String, dynamic> symbolTable, Fact fact) {
    switch (_comparisonNode.operation) {
      case "<":
        num lvalue = num.parse(_lhs.getValue(symbolTable, fact)) ?? 0;
        num rvalue = num.parse(_rhs.getValue(symbolTable, fact)) ?? 0;
        return lvalue < rvalue;
      case ">":
        num lvalue = num.parse(_lhs.getValue(symbolTable, fact)) ?? 0;
        num rvalue = num.parse(_rhs.getValue(symbolTable, fact)) ?? 0;
        return lvalue > rvalue;
      case "<=":
        num lvalue = num.parse(_lhs.getValue(symbolTable, fact)) ?? 0;
        num rvalue = num.parse(_rhs.getValue(symbolTable, fact)) ?? 0;
        return lvalue <= rvalue;
      case ">=":
        num lvalue = num.parse(_lhs.getValue(symbolTable, fact)) ?? 0;
        num rvalue = num.parse(_rhs.getValue(symbolTable, fact)) ?? 0;
        return lvalue >= rvalue;
      case "==":
        return 0 ==
            _lhs
                .getValue(symbolTable, fact)
                .compareTo(_rhs.getValue(symbolTable, fact));

      default:
    }

    return false;
  }

  String toString() {
    return "{Condition: ${_lhs.getName()} ${_comparisonNode.getName()} ${_rhs.getName()} }";
  }
}
