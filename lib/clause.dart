import 'assignment.dart';
import 'condition.dart';

class Clause
{
  String _type;
  List<Assignment> _assignments;
  List<Condition> _conditions;

  Clause(this._type)
  {
    _assignments = new List();
    _conditions = new List();
  }

  addAssignment(Assignment a)
  {
    _assignments.add(a);
  }

  addCondition(Condition c)
  {
    _conditions.add(c);
  }
}