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
String code = r"""rule "weekly saver for bob"
  when
      SimpleFact( name == "Ewout", $avg: average(amount))
  then
      insert Achievement( "weekly saver", "...", Badges.2 )
end
""";

main() {
  Lexer lexer = new Lexer(code);
  var tokens = lexer.getTokenList();
  //tokens.forEach((e) => print(e) );

  Parser parser = new Parser(tokens);

  RuleEngine ruleEngine = new RuleEngine(parser.buildTree());

  Fact fact = new SimpleFact("Bob", 0);
  ruleEngine.insertFact(fact);
  fact = new SimpleFact("Ewout", 120);
  ruleEngine.insertFact(fact);
  fact = new SimpleFact("Ewout", 110);
  ruleEngine.insertFact(fact);
  fact = new SimpleFact("Ewout", 90);
  ruleEngine.insertFact(fact);
  fact = new SimpleFact("Ewout", 80);
  ruleEngine.insertFact(fact);
  fact = new SimpleFact("Ewout", 80);
  ruleEngine.insertFact(fact);
  fact = new SimpleFact("Jef", 100000);
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

  @override
  String toString() {
    return "$_name: $_amount";
  }
}
