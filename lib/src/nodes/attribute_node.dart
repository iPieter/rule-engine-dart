import 'package:rule_engine/src/fact.dart';

import 'node.dart';

class AttributeNode extends Node {
  final String _name;

  const AttributeNode(this._name);

  String getName() {
    return _name;
  }

  @override
  String? getValue(
    Map<String, dynamic> symbolTable, [
    List<Fact> facts = const [],
    Fact? fact,
  ]) {
    return fact?.attributeMap()[_name].toString();
  }
}
