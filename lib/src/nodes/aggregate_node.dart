import 'package:rule_engine/src/fact.dart';

import 'node.dart';

class AggregateNode extends Node {
  final String _operation;
  final String _attribute;

  const AggregateNode(this._operation, this._attribute);

  String getName() {
    return "{AggregateNode: $_operation($_attribute)}";
  }

  @override
  String? getValue(
    Map<String, dynamic> symbolTable, [
    List<Fact> facts = const [],
    Fact? fact,
  ]) {
    switch (_operation) {
      case "sum":
        num sum = 0;
        for (Fact f in facts) {
          sum += f.attributeMap()[_attribute];
        }

        if (fact != null) {
          sum += fact.attributeMap()[_attribute];
        }

        return sum.toString();
      case "average":
        num sum = 0;
        for (Fact f in facts) {
          sum += f.attributeMap()[_attribute];
        }

        if (fact != null) {
          sum += fact.attributeMap()[_attribute];
        }

        return (sum / (facts.length + 1)).toString();
      case "min":
        num min = double.infinity;
        for (Fact f in facts) {
          if (min > f.attributeMap()[_attribute])
            min = f.attributeMap()[_attribute];
        }

        if (fact != null) {
          if (min > fact.attributeMap()[_attribute]) {
            min = fact.attributeMap()[_attribute];
          }
        }

        return min.toString();
      case "max":
        num max = double.negativeInfinity;
        for (Fact f in facts) {
          if (max < f.attributeMap()[_attribute])
            max = f.attributeMap()[_attribute];
        }

        if (fact != null) {
          if (max < fact.attributeMap()[_attribute]) {
            max = fact.attributeMap()[_attribute];
          }
        }

        return max.toString();
      default:
        return "";
    }
  }
}
