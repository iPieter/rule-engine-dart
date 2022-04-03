import 'package:rule_engine/src/fact.dart';

import 'node.dart';

class ComparisonNode extends Node {
  final String operation;

  const ComparisonNode(this.operation);

  String getName() {
    return "{ComparisonNode: $operation}";
  }

  @override
  String? getValue(
    Map<String, dynamic> symbolTable, [
    List<Fact> facts = const [],
    Fact? fact,
  ]) {
    return operation;
  }
}
