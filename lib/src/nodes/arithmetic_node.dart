import 'dart:collection';

import 'package:rule_engine/src/fact.dart';

import 'node.dart';

class ArithmeticNode extends Node {
  Node startNode;
  Queue<String> operations = new DoubleLinkedQueue();
  Queue<Node> otherNodes = new DoubleLinkedQueue();

  ArithmeticNode(Node startNode) {
    this.startNode = startNode;
  }

  String getName() {
    return "{Expression: $startNode $operations $otherNodes}";
  }

  addOperation(String ops, Node node) {
    operations.add(ops);
    otherNodes.add(node);
  }

  @override
  String getValue(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
    String initialValue = startNode.getValue(symbolTable, facts, fact);

    while (operations.isNotEmpty) {
      var operation = operations.removeFirst();
      var node = otherNodes.removeFirst();

      var val = node.getValue(symbolTable, facts, fact);

      switch (operation) {
        case "+":
          initialValue =
              (num.tryParse(initialValue) + num.tryParse(val)).toString();
          break;
        case "-":
          initialValue =
              (num.tryParse(initialValue) - num.tryParse(val)).toString();
          break;
        case "/":
          initialValue =
              (num.tryParse(initialValue) / num.tryParse(val)).toString();
          break;
        case "*":
          initialValue =
              (num.tryParse(initialValue) * num.tryParse(val)).toString();
          break;
        default:
          throw new ArgumentError("Unknow operation.");
      }
    }

    return initialValue;
  }

  @override
  String toString() {
    StringBuffer stringBuffer = new StringBuffer(startNode);
    for (int i = 0; i < operations.length; i++) {
      stringBuffer.write(operations.elementAt(i));
      stringBuffer.write(otherNodes.elementAt(i));
    }

    return stringBuffer.toString();
  }
}
