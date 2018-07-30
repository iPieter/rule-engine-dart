import 'package:rule_engine/fact.dart';

import 'node.dart';

class AttributeNode extends Node {
  String _name;
  AttributeNode(this._name);

  String getName() {
    return _name;
  }

  @override
  String getValue(Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    return fact.attributeMap()[_name].toString();
  }
}
