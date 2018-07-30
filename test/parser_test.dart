import 'package:rule_engine/lexer.dart';
import 'package:rule_engine/parser.dart';
import 'package:test/test.dart';

import 'package:rule_engine/rule_engine.dart';

void main() {
  test('Parser and lexer test', () {
    String code = r"""
rule "weekly saver"
  when
      Expense( $1 : sum( amount ) ) over Window( start : "1969-07-20 00:00:00", length : Duration(days:2) )
  then
      insert Achievement( "weekly saver", "...", Badges.2 )
end
""";
    String answer =
        r"""{Rule: weekly saver, clauses:[{Clause: Expense, [{Assignment: {SymbolNode: $1} : {AggregateNode: sum(amount)} }], [] over {Window: start:1969-07-20 00:00:00, end:, duration:{days: 2} }}] }""";
    Lexer lexer = new Lexer(code);
    var tokens = lexer.getTokenList();
    //tokens.forEach((e) => print(e) );

    Parser parser = new Parser(tokens);
    expect(parser.buildTree()[0].toString(), answer);
  });
}
