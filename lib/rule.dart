import "clause.dart";
import 'consequence.dart';

class Rule
{
  String _name;
  List<Clause> _clauses;
  Consequence consequence;

  Rule(this._name)
  {
    _clauses = new List();
  }

  addClause( Clause c )
  {
    _clauses.add(c);
  }

  toString()
  {
    return "{Rule: $_name, clauses:$_clauses }";
  }
}