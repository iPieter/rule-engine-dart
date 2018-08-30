import 'package:rule_engine/src/fact.dart';

import 'node.dart';

class LiteralNode extends Node {
  String _value;

  LiteralNode(this._value);

  String getName() {
    return _value;
  }

  @override
  String getValue(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    return _value;
  }
}
