import 'package:rule_engine/rule_engine.dart';
import 'package:rule_engine/src/network.dart';
import 'package:test/test.dart';

void main() {
  test('Simple compilation test', _basicTest);
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
  expect(network.typeNodes["Expense"].nodes["amount"].runtimeType.toString(),
      equals("MemoryAlphaNode"));
  network.typeNodes.forEach((k, v) {
    print("type: $k");
    v.nodes.forEach((ak, av) {
      print("\tattr: $ak");
    });
  });
}
