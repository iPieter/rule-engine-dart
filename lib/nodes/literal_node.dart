import 'package:rule_engine/fact.dart';

import 'node.dart';

class LiteralNode extends Node {
  String _value;

  LiteralNode(this._value);

  String getName() {
    return _value;
  }

  @override
  String getValue(Map<String, dynamic> symbolTable, Fact fact) {
    return _value;
  }
}
