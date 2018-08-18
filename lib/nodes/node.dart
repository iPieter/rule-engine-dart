import 'package:rule_engine/fact.dart';

abstract class Node {
  String getName();
  String getValue(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact);
}
