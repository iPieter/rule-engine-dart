import 'package:rule_engine/fact.dart';

import 'assignment.dart';
import 'condition.dart';
import 'window.dart';

class Clause {
  String _type;
  List<Assignment> _assignments;
  List<Condition> _conditions;
  Window window;

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
  /// - Type conditions should match
  /// - And finally, assignments should have no conflicts
  ///
  /// This function evaluates those requirements before returning true.
  bool evaluateClause(Map<String, dynamic> symbolTable, Fact fact) {
    bool validClause = true;
    validClause = validClause && fact.runtimeType.toString() == _type;

    Iterator<Condition> iterator = _conditions.iterator;
    while (validClause && iterator.moveNext()) {
      validClause =
          validClause && iterator.current.evaluateCondition(symbolTable, fact);
    }

    //now the clause should be true, in which case it will assign values, or false
    if (validClause) {
      for (var assignment in _assignments) {
        assignment.evaluateAssignment(symbolTable, fact);
        print(symbolTable);
      }
    }

    return validClause;
  }

  String toString() {
    return "{Clause: $_type, $_assignments, $_conditions over $window}";
  }
}
