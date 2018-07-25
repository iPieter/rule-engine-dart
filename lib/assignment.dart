import 'nodes/symbol_node.dart';
import 'nodes/node.dart';

class Assignment
{
  SymbolNode _symbolNode;
  Node _rhs;

  Assignment( this._symbolNode, this._rhs );

  String toString()
  {
    return "{Assignment: ${_symbolNode.getName()} : ${_rhs.getName()} }";
  }
}