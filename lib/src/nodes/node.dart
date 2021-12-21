import 'package:rule_engine/src/fact.dart';

abstract class Node {
  const Node();

  String getName();

  String? getValue(
    Map<String, dynamic> symbolTable, [
    List<Fact> facts = const [],
    Fact? fact,
  ]);
}
