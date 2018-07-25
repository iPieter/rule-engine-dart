import 'nodes/node.dart';
import 'nodes/comparison_node.dart';

class Condition
{
  Node _lhs;
  ComparisonNode _comparisonNode;
  Node _rhs;

  Condition(this._lhs, this._comparisonNode, this._rhs );

  String toString()
  {
    return "{Condition: ${_lhs.getName()} ${_comparisonNode.getName()} ${_rhs.getName()} }";
  }
}