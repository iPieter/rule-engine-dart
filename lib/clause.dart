import 'package:rule_engine/fact.dart';

import 'assignment.dart';
import 'condition.dart';

class Clause {
  String _type;
  List<Assignment> _assignments;
  List<Condition> _conditions;

  Clause(this._type) {
    _assignments = new List();
    _conditions = new List();
  }

  addAssignment(Assignment a) {
    _assignments.add(a);
  }

  addCondition(Condition c) {
    _conditions.add(c);
  }

  /// Each [Clause] has a few different options to evaluate:
  ///
  /// - The type of the fact should match the type of the clause
  /// - Assignments should have no conflicts
  /// - And finally, conditions should match
  ///
  /// This function evaluates those requirements before returning true.
  bool evaluateClause(Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    bool validClause = true;
    validClause = validClause && fact.runtimeType.toString() == _type;

    Map<String, dynamic> clauseTable = new Map();

    if (validClause) {
      for (var assignment in _assignments) {
        assignment.evaluateAssignment(symbolTable, clauseTable, facts, fact);
      }
    }

    Iterator<Condition> iterator = _conditions.iterator;
    while (validClause && iterator.moveNext()) {
      validClause = validClause && iterator.current.evaluateCondition(symbolTable, facts, clauseTable, fact);
    }

    //now the clause should be true, in which case it will assign values, or false
    if (validClause) {
      symbolTable.addAll(clauseTable);
    }

    return validClause;
  }

  String toString() {
    return "{Clause: $_type, $_assignments, $_conditions }";
  }
}
