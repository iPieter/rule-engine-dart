import "clause.dart";

class Rule
{
  String _name;
  List<Clause> _clauses;

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