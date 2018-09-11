import 'dart:collection';

import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/src/rule.dart';

/// This is the encapsulating class that contains the entire RETE network.
class Network {
  Map<String, TypeAlphaNode> _typeNodes = new HashMap();

  Network() {}

  void addRule(Rule r) {
    for (var clause in r.clauses) {
      //add the type alpha node if absent, and either way compile the clause
      _typeNodes
          .putIfAbsent(clause.type, () => new TypeAlphaNode())
          .compileClause(clause);
    }
  }
}

abstract class AlphaNode {
  /// When facts are propagated through the network, they are passed along
  /// whilst asserting different parts of the fact, which is now a Working
  /// Memory Element (WME).
  void propagate(Fact fact);
}

class TypeAlphaNode implements AlphaNode {
  Map<String, AlphaNode> _attributeNodes = new HashMap();

  /// Attributes of this rule engine's syntax are a bit difficult, since
  /// they might be an actual attribute node, or aggregates or symbol nodes.
  ///
  /// For this reason, if no attributes are suitable, an [MemoryAlphaNode] might
  /// follow directly. This is the same as in the [AttributeAlphaNode].
  void compileClause(Clause clause) {
    for (Condition condition in clause.conditions) {
      if (condition.hasStaticSide() &&
          !_attributeNodes.containsKey(condition.obtainStaticSide())) {
        var attributeAlphaNode = new AttributeAlphaNode();
        attributeAlphaNode.compileCondition(clause, 0);
      }
    }
  }

  /// When facts are propagated through the network, they are passed along
  /// whilst asserting different parts of the fact, which is now a Working
  /// Memory Element (WME).
  ///
  /// In this stage, the type is checked and if it matches, a
  @override
  void propagate(Fact fact) {
    if (_attributeNodes.containsKey(fact.runtimeType.toString()))
      _attributeNodes[fact.runtimeType.toString()].propagate(fact);
  }
}

class AttributeAlphaNode implements AlphaNode {
  ///The following nodes can be other [AttributeAlphaNode]s, or [MemoryAlphaNode]s.
  Map<String, AlphaNode> _nodes = new HashMap();

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
  void compileCondition(Clause clause, int position) {}
}

/// The RETE algorithm doesn't describe how to handle dynamic values, like the
/// sum or sliding window functions offered in this package. In this implementation,
/// these reside in a [DynamicAlphaNode] just before a [MemoryAlphaNode].
class DynamicAlphaNode implements AlphaNode {}

/// The [MemoryAlphaNode] is special type of alpha node, since it is not only
/// part of the network, but also provides a cache. These are placed before the
/// beta part of the network. In theory, this can be placed on every level,
/// after an [AlphaNode]. But this only negatively impacts memory usage, without
/// any additional speedup.
///
/// Since this is the first input to the beta network, this class keeps track of
/// the execution state of all facts.
class MemoryAlphaNode implements AlphaNode {
  Map<Fact, bool> alphaMemory = new LinkedHashMap();
}
