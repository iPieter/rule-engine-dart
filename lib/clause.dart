import 'assignment.dart';
import 'condition.dart';
import 'window.dart';

class Clause
{
  String _type;
  List<Assignment> _assignments;
  List<Condition> _conditions;
  Window window;

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

  String toString()
  {
    return "{Clause: $_type, $_assignments, $_conditions over $window}";
  }
}