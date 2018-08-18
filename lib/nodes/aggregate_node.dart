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
  String getValue(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    switch (_operation) {
      case "sum":
        num sum = 0;
        for (Fact f in facts) {
          sum += f.attributeMap()[_attribute];
        }
        sum += fact.attributeMap()[_attribute];
        return sum.toString();
      case "average":
        num sum = 0;
        for (Fact f in facts) {
          sum += f.attributeMap()[_attribute];
        }
        sum += fact.attributeMap()[_attribute];
        return (sum / (facts.length + 1)).toString();

        break;
      default:
    }
  }
}
