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

abstract class AlphaNode {}

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
        attributeAlphaNode.compileCondition(condition);
      }
    }
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
  void compileCondition(Condition clause) {}
}

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
