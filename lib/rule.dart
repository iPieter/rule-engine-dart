import 'package:rule_engine/fact.dart';

import "clause.dart";
import 'consequence.dart';

class Rule {
  String _name;
  List<Clause> _clauses;
  Consequence consequence;

  Rule(this._name) {
    _clauses = new List();
  }

  addClause(Clause c) {
    _clauses.add(c);
  }

  bool evaluateRule(Fact fact, List<Fact> facts) {
    bool firstFact = false;
    Map<Clause, Fact> clauseMap = new Map();
    Map<String, dynamic> _symbolTable = new Map();

    for (Clause clause in _clauses) {
      bool isTrueFact = clause.evaluateClause(_symbolTable, fact);
      firstFact = firstFact || isTrueFact;

      if (isTrueFact) {
        clauseMap[clause] = fact;
      }
    }

    //if the inserted fact (firstFact) evaluates to true, all other facts have to find a matching value
    for (Clause clause in _clauses) {
      if (!clauseMap.containsKey(clause)) {
        //find a fact that matches
        Fact f;
        Iterator<Fact> factsIterator = facts.iterator;
        while (f == null && factsIterator.moveNext()) {
          print("evaluating ${factsIterator.current} for $clause");
          if (clause.evaluateClause(_symbolTable, factsIterator.current)) {
            f = factsIterator.current;
            clauseMap[clause] = f;
          }
        }
      }
    }

    //finally check of each clause has a fact
    bool allClausesHaveAFact = true;
    for (Clause clause in _clauses) {
      allClausesHaveAFact = allClausesHaveAFact && clauseMap.containsKey(clause);
    }

    return allClausesHaveAFact;
  }

  toString() {
    return "{Rule: $_name, clauses:$_clauses }";
  }
}
