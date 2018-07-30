import 'package:rule_engine/fact.dart';

import "clause.dart";
import 'consequence.dart';

class Rule {
  String _name;
  List<Clause> _clauses;
  Consequence consequence;
  Map<Clause, List<Fact>> _matchedFacts;

  Rule(this._name) {
    _clauses = new List();
    _matchedFacts = new Map();
  }

  addClause(Clause c) {
    _clauses.add(c);
    _matchedFacts[c] = new List();
  }

  bool evaluateRule(Fact fact, List<Fact> facts) {
    bool firstFact = false;
    Map<Clause, Fact> clauseMap = new Map();
    Map<String, dynamic> _symbolTable = new Map();

    for (Clause clause in _clauses) {
      bool isTrueFact = clause.evaluateClause(_symbolTable, _matchedFacts[clause], fact);
      firstFact = firstFact || isTrueFact;

      if (isTrueFact) {
        clauseMap[clause] = fact;
        _matchedFacts[clause].add(fact);
      }
    }

    //if the inserted fact (firstFact) evaluates to true, all other facts have to find a matching value
    for (Clause clause in _clauses) {
      if (!clauseMap.containsKey(clause) && _matchedFacts[clause].length > 0) {
        clauseMap[clause] = _matchedFacts[clause].first;
      }
    }

    //finally check of each clause has a fact
    bool allClausesHaveAFact = true;
    for (Clause clause in _clauses) {
      allClausesHaveAFact = allClausesHaveAFact && clauseMap.containsKey(clause);
    }

    print(_symbolTable);

    return allClausesHaveAFact;
  }

  toString() {
    return "{Rule: $_name, clauses:$_clauses }";
  }
}
