import 'node.dart';

class LiteralNode extends Node
{
  String _value;

  LiteralNode(this._value);

  String getName()
  {
    return "{LiteralNode: $_value}";
  }
}