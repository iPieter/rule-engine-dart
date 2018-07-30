import 'package:rule_engine/fact.dart';

import 'node.dart';

class SymbolNode extends Node {
  String _name;
  SymbolNode(this._name);

  String getName() {
    return "{SymbolNode: $_name}";
  }

  @override
  String getValue(Map<String, dynamic> symbolTable, Fact fact) {
    return symbolTable[_name];
  }
}
