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
  } catch (e) {
    thrownError = true;
  }

  expect(thrownError, equals(true));
}

void _windowRules() {
  String code = r"""
rule "windows"
  when
    SimpleFact( created in Window( length: Duration( days: 31 ) ) )
    SimpleFact( created in Window( start: "1969-07-20 00:00:00", length: Duration( days: 31 ) ) )
    SimpleFact( created in Window( end: "2018-07-20 23:59:59",length: Duration( days: 31 ) ) )
  then
      publish Achievement( "test" )
end
""";

  bool thrownError = false;

  try {
    Lexer lexer = new Lexer(code);
    Parser parser = new Parser(lexer.getTokenList());
    var result = parser.buildTree();
    expect(result.length, equals(1));
  } catch (e) {
    thrownError = true;
  }

  expect(thrownError, equals(false));
}

void main() {
  test('Basic test: one rule with one clause', _basicTest);
  test('Negation test with one rule with one clause', _notTest);
  test('Invalid symbol for assignment', _invalidAssignmentTest);
  test('Different window declarations', _windowRules);
}
