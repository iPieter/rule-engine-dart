import 'package:rule_engine/src/fact.dart';

abstract class Node {
  String getName();
  String getValue(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact);
}
