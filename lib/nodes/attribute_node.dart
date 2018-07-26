import 'node.dart';

class AttributeNode extends Node
{
  String _name;
  AttributeNode(this._name);

  String getName()
  {
    return "{AttributeNode: $_name}";
  }
}