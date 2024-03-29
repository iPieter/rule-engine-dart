import 'package:rule_engine/src/fact.dart';

import 'assignment.dart';
import 'condition.dart';

class Clause {
  final String _type;
  final bool negated;
  final List<Assignment> _assignments = [];
  final List<Condition> _conditions = [];

  Clause(String type, this.negated) : _type = type;

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
  bool evaluateClause(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    bool validClause = true;
    validClause = validClause && fact.runtimeType.toString() == _type;

    Map<String, dynamic> clauseTable = Map();

    if (validClause) {
      for (final assignment in _assignments) {
        assignment.evaluateAssignment(symbolTable, clauseTable, facts, fact);
      }
    }

    Iterator<Condition> iterator = _conditions.iterator;
    while (validClause && iterator.moveNext()) {
      validClause = validClause &&
          iterator.current
              .evaluateCondition(symbolTable, facts, clauseTable, fact);
    }

    //when the clause is negated, no symbols will be stored and the entire clause will yield the oposite value
    //validClause = negated ? !validClause : validClause;

    //now the clause should be true, in which case it will assign values, or false
    if (validClause && !negated) {
      symbolTable.addAll(clauseTable);
    }

    return validClause;
  }

  String toString() {
    return "{Clause: $_type, $_assignments, $_conditions }";
  }
}
