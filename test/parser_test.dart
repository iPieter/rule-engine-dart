import 'package:rule_engine/lexer.dart';
import 'package:rule_engine/parser.dart';
import 'package:test/test.dart';

void _basicTest() {
  String code = r"""
rule "weekly saver"
  when
      Expense( amount > 10 )
  then
      publish Achievement( "test" )
end
""";
  Lexer lexer = new Lexer(code);
  Parser parser = new Parser(lexer.getTokenList());
  var result = parser.buildTree();
  expect(result.length, equals(1));
}

void _notTest() {
  String code = r"""
rule "weekly saver"
  when
      not Expense( amount > 10 )
  then
      publish Achievement( "test" )
end
""";
  Lexer lexer = new Lexer(code);
  Parser parser = new Parser(lexer.getTokenList());
  var result = parser.buildTree();
  expect(result.length, equals(1));
}

void _invalidAssignmentTest() {
  String code = r"""
rule "weekly saver"
  when
      not Expense( $amount = amount )
  then
      publish Achievement( "test" )
end
""";

  bool thrownError = false;

  try {
    Lexer lexer = new Lexer(code);
    Parser parser = new Parser(lexer.getTokenList());
    var result = parser.buildTree();
    print(result[0]);
  } catch (e) {
    thrownError = true;
  }

  expect(thrownError, equals(true));
}

void main() {
  test('Basic test: one rule with one clause', _basicTest);
  test('Negation test with one rule with one clause', _notTest);
  test('Invalid symbol for assignment', _invalidAssignmentTest);
}
