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

  bool evaluateRule(Fact fact, List<Function> callbacks) {
    bool firstFact = true;
    Map<Clause, Fact> clauseMap = new Map();
    Map<String, dynamic> _symbolTable = new Map();

    var iterator = _clauses.iterator;
    while (firstFact && iterator.moveNext()) {
      var clause = iterator.current;
      bool isTrueFact = clause.evaluateClause(_symbolTable, _matchedFacts[clause], fact);
      firstFact = firstFact && isTrueFact;

      if (isTrueFact) {
        clauseMap[clause] = fact;
        _matchedFacts[clause].add(fact);
      }
    }

    bool allClausesHaveAFact = firstFact;

    if (firstFact) {
      //if the inserted fact (firstFact) evaluates to true, all other facts have to find a matching value
      for (Clause clause in _clauses) {
        if (!clauseMap.containsKey(clause) && _matchedFacts[clause].length > 0) {
          clauseMap[clause] = _matchedFacts[clause].first;
        }
      }

      //finally check of each clause has a fact
      for (Clause clause in _clauses) {
        allClausesHaveAFact = allClausesHaveAFact && clauseMap.containsKey(clause);
      }
    }

    //finally, the rule can be considered true or false, in which case the consequence has to be executed
    if (allClausesHaveAFact && firstFact) {
      for (Function callback in callbacks) {
        Function.apply(callback, [consequence.getType(), consequence.getArguments(_symbolTable, null, null)]);
      }
    }

    return allClausesHaveAFact;
  }

  toString() {
    return "{Rule: $_name, clauses:$_clauses }";
  }
}
