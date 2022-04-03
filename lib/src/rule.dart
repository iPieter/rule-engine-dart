import 'package:rule_engine/src/fact.dart';

import "clause.dart";
import 'consequence.dart';

class Rule {
  final String _name;
  final List<Clause> _clauses = [];
  final Map<Clause, List<Fact>> _matchedFacts = {};
  Consequence? consequence;

  Rule(this._name);

  addClause(Clause c) {
    _clauses.add(c);
    _matchedFacts[c] = [];
  }

  bool evaluateRule(Fact fact, List<Function> callbacks) {
    final Map<Clause, Fact> clauseMap = Map();
    final Map<String, dynamic> _symbolTable = Map();
    bool firstFact = true;
    _symbolTable["\$ruleName"] = _name;

    final iterator = _clauses.iterator;
    while (iterator.moveNext()) {
      final clause = iterator.current;
      final matchedFact = _matchedFacts[clause]!;
      bool isTrueFact = clause.evaluateClause(
        _symbolTable,
        matchedFact,
        fact,
      );
      firstFact = firstFact && (isTrueFact || clause.negated);
      //isTrueFact = clause.negated ? !isTrueFact : isTrueFact;

      if (isTrueFact) {
        clauseMap[clause] = fact;
        matchedFact.add(fact);
      }
    }

    bool allClausesHaveAFact = firstFact;

    if (firstFact) {
      //if the inserted fact (firstFact) evaluates to true, all other facts have to find a matching value
      for (Clause clause in _clauses) {
        final matchedFact = _matchedFacts[clause]!;
        if (!clauseMap.containsKey(clause) && matchedFact.length > 0) {
          clauseMap[clause] = matchedFact.first;
        }
      }

      //finally check of each clause has a fact
      for (Clause clause in _clauses) {
        allClausesHaveAFact = allClausesHaveAFact &&
            ((clauseMap.containsKey(clause) && !clause.negated) ||
                (!clauseMap.containsKey(clause) && clause.negated));
      }
    }

    //finally, the rule can be considered true or false, in which case the consequence has to be executed
    if (allClausesHaveAFact && firstFact) {
      for (Function callback in callbacks) {
        Function.apply(
          callback,
          [
            consequence?.getType(),
            consequence?.getArguments(_symbolTable),
          ],
        );
      }
    }

    return allClausesHaveAFact;
  }

  toString() {
    return "{Rule: $_name, clauses:$_clauses }";
  }
}
