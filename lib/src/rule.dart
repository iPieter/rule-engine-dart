import 'package:rule_engine/src/fact.dart';

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
    // firstFact needs to find at least one fact that evaluates to true
    bool firstFact = false;

    // whilst in the end, all clauses need to have at least one fact
    bool allClausesHaveAFact = true;

    Map<Clause, Fact> clauseMap = new Map();
    Map<String, dynamic> _symbolTable = new Map();
    _symbolTable["\$ruleName"] = _name;
    print("evaluating for $fact");
    var iterator = _clauses.iterator;
    while (iterator.moveNext()) {
      var clause = iterator.current;
      bool isTrueFact =
          clause.evaluateClause(_symbolTable, _matchedFacts[clause], fact);
      firstFact = firstFact ||
          (isTrueFact && !clause.negated) ||
          (!isTrueFact && clause.negated);

      //isTrueFact = clause.negated ? !isTrueFact : isTrueFact;

      if (isTrueFact) {
        print("adding $fact");
        clauseMap[clause] = fact;
        _matchedFacts[clause].add(fact);
      }
    }

    if (firstFact) {
      //if the inserted fact (firstFact) evaluates to true, all other facts have to find a matching value
      for (Clause clause in _clauses) {
        if (!clauseMap.containsKey(clause) &&
            _matchedFacts[clause].length > 0) {
          clauseMap[clause] = _matchedFacts[clause].first;
          clause.evaluateClause(
              _symbolTable,
              _matchedFacts[clause]
                  .skipWhile((f) => f == clauseMap[clause])
                  .toList(),
              clauseMap[clause]);
        }
      }

      //finally check of each clause has a fact
      for (Clause clause in _clauses) {
        allClausesHaveAFact = allClausesHaveAFact &&
            ((clauseMap.containsKey(clause) && !clause.negated) ||
                (!clauseMap.containsKey(clause) && clause.negated));
        print("$clause : $allClausesHaveAFact");
      }
    }

    print(
        "Finally, do all clauses have a fact? $allClausesHaveAFact, is it new? $firstFact");

    //finally, the rule can be considered true or false, in which case the consequence has to be executed
    if (allClausesHaveAFact && firstFact) {
      for (Function callback in callbacks) {
        Function.apply(callback, [
          consequence.getType(),
          consequence.getArguments(_symbolTable, null, null)
        ]);
      }
    }

    return allClausesHaveAFact;
  }

  toString() {
    return "{Rule: $_name, clauses:$_clauses }";
  }
}
