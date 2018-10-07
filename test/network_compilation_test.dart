import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/src/network.dart';
import 'package:test/test.dart';

void main() {
  test('Simple compilation test', _basicTest);
  test('Two static conditions in one rule test', _twoConditionsTest);
}

_basicTest() {
  var network = new Network();

  var code = r"""rule "weekly saver"
  when
      Expense( amount > 10 )
  then
      publish Achievement( "test" )
end
""";
  Lexer lexer = new Lexer(code);
  Parser parser = new Parser(lexer.getTokenList(), code);
  var result = parser.buildTree();

  network.addRule(result[0]);
  expect(network.typeNodes.length, equals(1));
  expect(network.typeNodes["Expense"].nodes.length, equals(1));
  expect(network.typeNodes["Expense"].nodes["amount"].runtimeType,
      equals(MemoryAlphaNode));
}

_twoConditionsTest() {
  var network = new Network();

  var code = r"""rule "weekly saver"
  when
      Expense( amount > 10, name == "Bob" )
  then
      publish Achievement( "test" )
end
""";
  Lexer lexer = new Lexer(code);
  Parser parser = new Parser(lexer.getTokenList(), code);
  var result = parser.buildTree();

  network.addRule(result[0]);
  expect(network.typeNodes.length, equals(1));
  expect(network.typeNodes["Expense"].nodes.length, equals(1));
  expect(network.typeNodes["Expense"].nodes["amount"].runtimeType,
      equals(AttributeAlphaNode));
  var n = network.typeNodes["Expense"].nodes["amount"] as AttributeAlphaNode;
  expect(n.nodes.length, equals(1));
  expect(n.nodes["name"].runtimeType, equals(MemoryAlphaNode));
}

printNodes(Network network) {
  network.typeNodes.forEach((k, v) {
    print("type: $k");
    v.nodes.forEach((ak, av) {
      print("\tattr: $ak");
    });
  });
}
