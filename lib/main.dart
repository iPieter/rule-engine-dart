import 'package:rule_engine/fact.dart';
import 'package:rule_engine/rule.dart';
import 'package:rule_engine/rule_engine.dart';

import 'lexer.dart';
import 'parser.dart';

var test = """
      Expense( \$2: sum( amount ) < \$1 ) over Duration( {days: 7}, substract( {days: 7} ) )
      Expense( \$3: sum( amount ) < \$2 ) over Duration( {days: 7}, substract( {days: 14} ) )
      Expense( \$4: sum( amount ) < \$3 ) over Duration( {days: 7}, substract( {days: 21} ) )
""";
String code = r"""
rule "weekly saver"
  when
      SimpleFact( 100 < amount )
  then
      insert Achievement( "weekly saver", "...", Badges.2 )
end

rule "weekly saver 2"
  when
      SimpleFact( 20 < amount )
  then
      insert Achievement( "weekly saver", "...", Badges.2 )
end

rule "bob"
  when
      SimpleFact( name == "Bob", $name: name, $language: "nl", $other: $language )
  then
      insert Achievement( "weekly saver", "...", Badges.2 )
end

rule "weekly saver for bob"
  when
      SimpleFact( name == "Bob", amount > 20 )

  then
      insert Achievement( "weekly saver", "...", Badges.2 )
      insert Achievement( "weekly saver", "...", Badges.2 )
end
""";

main() {
  Lexer lexer = new Lexer(code);
  var tokens = lexer.getTokenList();
  //tokens.forEach((e) => print(e) );

  Parser parser = new Parser(tokens);

  RuleEngine ruleEngine = new RuleEngine(parser.buildTree());

  Fact fact = new SimpleFact("Bob", 75);
  ruleEngine.insertFact(fact);
}

class SimpleFact extends Fact {
  String _name;
  int _amount;

  SimpleFact(this._name, this._amount);

  @override
  Map<String, dynamic> attributeMap() {
    Map<String, dynamic> attributes = new Map<String, dynamic>();
    attributes["name"] = _name;
    attributes["amount"] = _amount;
    return attributes;
  }
}
