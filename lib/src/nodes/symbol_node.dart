import 'package:rule_engine/src/fact.dart';

import 'node.dart';

class SymbolNode extends Node {
  final String _name;

  const SymbolNode(this._name);

  String getName() {
    return _name;
  }

  @override
  String? getValue(
    Map<String, dynamic> symbolTable, [
    List<Fact> facts = const [],
    Fact? fact,
  ]) {
    return symbolTable[_name];
  }
}
