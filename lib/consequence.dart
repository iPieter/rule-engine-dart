import 'package:rule_engine/fact.dart';
import 'package:rule_engine/nodes/node.dart';

class Consequence {
  String _type;
  List<Node> _arguments;

  Consequence(this._type) {
    _arguments = new List();
  }

  String getType() {
    return _type;
  }

  List<String> getArguments(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    List<String> args = new List();

    for (Node node in _arguments) {
      args.add(node.getValue(symbolTable, facts, fact));
    }

    return args;
  }

  addArgument(Node arg) {
    _arguments.add(arg);
  }
}
