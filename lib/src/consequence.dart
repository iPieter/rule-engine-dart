import 'package:rule_engine/src/fact.dart';
import 'package:rule_engine/src/nodes/node.dart';

class Consequence {
  final String _type;
  final List<Node> _arguments = [];

  Consequence(this._type);

  String getType() {
    return _type;
  }

  List<String> getArguments(
    Map<String, dynamic> symbolTable, [
    List<Fact> facts = const [],
    Fact? fact,
  ]) {
    final args = <String>[];

    for (Node node in _arguments) {
      final value = node.getValue(symbolTable, facts, fact);
      if (value == null) continue;
      args.add(value);
    }

    return args;
  }

  addArgument(Node arg) {
    _arguments.add(arg);
  }
}
