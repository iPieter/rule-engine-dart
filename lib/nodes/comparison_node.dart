import 'node.dart';

class ComparisonNode extends Node
{
  String _operation;

  ComparisonNode(this._operation);

  String getName()
  {
    return "{ComparisonNode: $_operation}";
  }
}