import 'package:rule_engine/src/lexer.dart';
import 'package:rule_engine/src/parser.dart';
import 'package:test/test.dart';

void _booleanTest() {
  String code = r"""
rule "weekly saver"
  when
      Expense( amount > 10 )
      Expense( $amount > 10 )
      Expense( $amountTwo > $amount )
  then
      publish Achievement( "test" )
end
""";
  Lexer lexer = new Lexer(code);
  Parser parser = new Parser(lexer.getTokenList(), code);
  var result = parser.buildTree();
  print(result);
  expect(result[0].clauses[0].conditions[0].hasStaticSide(), equals(true));
  expect(result[0].clauses[1].conditions[0].hasStaticSide(), equals(true));
  expect(result[0].clauses[2].conditions[0].hasStaticSide(), equals(false));
}

void _rightSideTest() {
  String code = r"""
rule "weekly saver"
  when
      Expense( amount > 10 )
      Expense( $amount > 10 )
      Expense( 10 < $amount  )
      Expense( $amountTwo > $amount )
      Expense( 10 < amount )
  then
      publish Achievement( "test" )
end
""";
  Lexer lexer = new Lexer(code);
  Parser parser = new Parser(lexer.getTokenList(), code);
  var result = parser.buildTree();
  print(result);
  expect(
      result[0].clauses[0].conditions[0].obtainStaticSide(), equals("amount"));
  expect(result[0].clauses[1].conditions[0].obtainStaticSide(), equals("10"));
  expect(result[0].clauses[2].conditions[0].obtainStaticSide(), equals("10"));
  expect(result[0].clauses[3].conditions[0].hasStaticSide(), equals(false));
  expect(result[0].clauses[3].conditions[0].obtainStaticSide(), isNull);
  expect(
      result[0].clauses[4].conditions[0].obtainStaticSide(), equals("amount"));
}

void main() {
  test('Has static side tests', _booleanTest);
  test('Correct static side tests', _rightSideTest);
}
