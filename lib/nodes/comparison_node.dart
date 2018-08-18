import 'package:rule_engine/fact.dart';

import 'node.dart';

class ComparisonNode extends Node {
  String operation;

  ComparisonNode(this.operation);

  String getName() {
    return "{ComparisonNode: $operation}";
  }

  @override
  String getValue(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    return operation;
  }
}
