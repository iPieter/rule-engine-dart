import 'package:rule_engine/src/fact.dart';

import 'node.dart';

class ArithmeticNode extends Node {
  Node startNode;
  List<String> operations;
  List<Node> otherNodes;

  ArithmeticNode(Node startNode){
    this.startNode = startNode;
  }

  String getName() {
    return "{Expression: $startNode $operations $otherNodes}";
  }

  addOperation(String ops, Node node){
    operations.add(ops);
    otherNodes.add(node);
  }

  @override
  String getValue(
      Map<String, dynamic> symbolTable, List<Fact> facts, Fact fact) {
      /// This should implement something like this:
      /// 
      /// initialValue = startNode.evaluate()
      /// 
      /// do{
      ///   operation = operations.pop()
      ///   node = otherNodes.pop()
      /// 
      ///   val = node.evaluate()  
      ///  initialValue = initialValue <operation> value
      ///
      /// }while( operations not empty )
      /// 
      return startNode.getValue(symbolTable, facts, fact);
  }
}
