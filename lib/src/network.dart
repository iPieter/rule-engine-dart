import 'dart:collection';

import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/src/rule.dart';

/// This is the encapsulating class that contains the entire RETE network.
class Network {
  Map<String, AttributeAlphaNode> typeNodes = new HashMap();
  List<BetaNode> _betanodes = new List();
  Network() {}

  void addRule(Rule r) {
    var betanode = new BetaNode();

    for (var clause in r.clauses) {
      // to accurately compile the graph, the conditions are split in advance
      var dynamicConditions = new List<Condition>();
      var staticConditions = new List<Condition>();

      for (var condition in clause.conditions) {
        if (condition.hasStaticSide())
          staticConditions.add(condition);
        else
          dynamicConditions.add(condition);
      }

      // all clauses of one rule end in the same [BetaNode]
      // add the type alpha node if absent, and either way compile the clause
      var memorynode = new MemoryAlphaNode(dynamicConditions);
      typeNodes
          .putIfAbsent(clause.type, () => new AttributeAlphaNode())
          .compileCondition(clause, 0, memorynode);
      betanode.addMemoryNode(memorynode);
    }

    _betanodes.add(betanode);

    print("compiled");
  }

  void addFact(Fact f) {}
}

abstract class AlphaNode {
  /// When facts are propagated through the network, they are passed along
  /// whilst asserting different parts of the fact, which is now a Working
  /// Memory Element (WME).
  void propagate(Fact fact);
}

/// [BetaNode]s contain symbolic links to [MemoryAlphaNode]s, which they use
/// for joining all those alpha networks together.
class BetaNode {
  List<MemoryAlphaNode> memoryNodes = new List();

  void addMemoryNode(MemoryAlphaNode memorynode) {
    memoryNodes.add(memorynode);
  }
}

class TypeAlphaNode implements AlphaNode {
  Map<String, AttributeAlphaNode> attributeNodes = new HashMap();

  /// Attributes of this rule engine's syntax are a bit difficult, since
  /// they might be an actual attribute node, or aggregates or symbol nodes.
  ///
  /// For this reason, if no attributes are suitable, an [MemoryAlphaNode] might
  /// follow directly. This is the same as in the [AttributeAlphaNode].
  void compileClause(Clause clause, BetaNode betanode) {
    // all these clauses end in one [MemoryAlphaNode] per clause, and then aggerated in a [BetaNode].

    // TODO: implement some checks for zero conditions
    var attributeAlphaNode =
        attributeNodes.putIfAbsent(clause.type, () => new AttributeAlphaNode());
  }

  /// When facts are propagated through the network, they are passed along
  /// whilst asserting different parts of the fact, which is now a Working
  /// Memory Element (WME).
  ///
  /// In this stage, the type is checked and, if it matches, propagated.
  @override
  void propagate(Fact fact) {
    if (attributeNodes.containsKey(fact.runtimeType.toString()))
      attributeNodes[fact.runtimeType.toString()].propagate(fact);
  }
}

class AttributeAlphaNode implements AlphaNode {
  ///The following nodes can be other [AttributeAlphaNode]s, or [MemoryAlphaNode]s.
  Map<String, AlphaNode> nodes = new HashMap();

  /// Attributes of this rule engine's syntax are a bit difficult, since
  /// they might be an actual attribute node, or aggregates or symbol nodes.
  ///
  /// For this reason, if no attributes are suitable, an [MemoryAlphaNode] might
  /// follow directly.
  ///
  /// Since rules might check more than one attribute, they can be chained. Of
  /// course, making sure static conditions come first will improve performance.
  /// Regardless of final order, this function will take the #[position] element
  /// of a clause and add it to the list.
  void compileCondition(
      Clause clause, int position, MemoryAlphaNode finalConditions) {
    print("compiling clause position $position");
    while (position < clause.conditions.length &&
        !clause.conditions[position].hasStaticSide()) {
      finalConditions.addCondition(clause.conditions[position]);
      position++;
    }

    print("skipped to clause position $position");

    if (position < clause.conditions.length) {
      if (clause.conditions[position].hasStaticSide()) {
        // there is a static side, thus use it for the following node
        var staticSide = clause.conditions[position].obtainStaticSide();
        if (!nodes.containsKey(staticSide)) {
          print("adding node for condition $staticSide");

          var attributeAlphaNode = new AttributeAlphaNode();
          nodes[staticSide] = attributeAlphaNode;
          attributeAlphaNode.compileCondition(
              clause, ++position, finalConditions);
        } else {
          var n = nodes[staticSide] as AttributeAlphaNode;
          n.compileCondition(clause, ++position, finalConditions);
          ;
        }
      } else {
        print(
            "clause doesn't have static side, but a static side is expected. Something is very wrong.");
      }
    }
  }

  @override
  void propagate(Fact fact) {
    // TODO: implement propagate
  }
}

/// The RETE algorithm doesn't describe how to handle dynamic values, like the
/// sum or sliding window functions offered in this package. In this implementation,
/// these reside in a [DynamicAlphaNode] just before a [MemoryAlphaNode].
class DynamicAlphaNode implements AlphaNode {
  @override
  void propagate(Fact fact) {
    // TODO: implement propagate
  }
}

/// The [MemoryAlphaNode] is special type of alpha node, since it is not only
/// part of the network, but also provides a cache. These are placed before the
/// beta part of the network. In theory, this can be placed on every level,
/// after an [AlphaNode]. But this only negatively impacts memory usage, without
/// any additional speedup.
///
/// Since this is the first input to the beta network, this class keeps track of
/// the execution state of all facts.
///
/// Asside from those responsabiliies, it also checks all dynamic conditions.
class MemoryAlphaNode implements AlphaNode {
  Map<Fact, bool> alphaMemory = new LinkedHashMap();
  List<Condition> finalConditions = new List();

  MemoryAlphaNode(this.finalConditions);

  void addCondition(Condition condition) {
    finalConditions.add(condition);
  }

  @override
  void propagate(Fact fact) {}
}
