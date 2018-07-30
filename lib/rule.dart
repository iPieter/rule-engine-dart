import 'package:rule_engine/fact.dart';

import "clause.dart";
import 'consequence.dart';

class Rule {
  String _name;
  List<Clause> _clauses;
  Consequence consequence;

  Map<String, dynamic> _symbolTable;

  Rule(this._name) {
    _clauses = new List();
    _symbolTable = new Map();
  }

  addClause(Clause c) {
    _clauses.add(c);
  }

  bool evaluateRule(Fact fact) {
    bool value = true;

    for (Clause clause in _clauses) {
      value = value && clause.evaluateClause(_symbolTable, fact);
    }

    return value;
  }

  toString() {
    return "{Rule: $_name, clauses:$_clauses }";
  }
}
