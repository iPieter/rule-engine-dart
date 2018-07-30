import 'package:rule_engine/fact.dart';

import 'nodes/symbol_node.dart';
import 'nodes/node.dart';

class Assignment {
  SymbolNode _symbolNode;
  Node _rhs;

  Assignment(this._symbolNode, this._rhs);

  bool evaluateAssignment(
      Map<String, dynamic> symbolTable, Map<String, dynamic> clauseTable, List<Fact> facts, Fact fact) {
    if (symbolTable.containsKey(_symbolNode.getName()) || clauseTable.containsKey(_symbolNode.getName())) {
      print(
          "Execution error: The symbol '${_symbolNode.getName()} is already assigned, double assignments are not allowed.");
      return false;
    }

    if (_rhs.runtimeType.toString() == "SymbolNode" &&
        _rhs.getValue(symbolTable, facts, fact) == null &&
        _rhs.getValue(clauseTable, facts, fact) == null) {
      print(
          "Execution error: The symbol '${_rhs.getName()} was not (yet) assigned when being assigned to another symbol.");
      return false;
    }

    clauseTable[_symbolNode.getName()] =
        _rhs.getValue(symbolTable, facts, fact) ?? _rhs.getValue(clauseTable, facts, fact);

    return true;
  }

  String toString() {
    return "{Assignment: ${_symbolNode.getName()} : ${_rhs.getName()} }";
  }
}
