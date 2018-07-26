import 'node.dart';

class SymbolNode extends Node
{
  String _name;
  SymbolNode(this._name);

  String getName()
  {
    return "{SymbolNode: $_name}";
  }
}