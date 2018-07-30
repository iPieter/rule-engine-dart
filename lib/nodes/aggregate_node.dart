import 'package:rule_engine/fact.dart';

import 'node.dart';

class AggregateNode extends Node {
  String _operation;
  String _attribute;

  AggregateNode(this._operation, this._attribute);

  String getName() {
    return "{AggregateNode: $_operation($_attribute)}";
  }

  @override
  String getValue(Map<String, dynamic> symbolTable, Fact fact) {
    return "0";
  }
}
