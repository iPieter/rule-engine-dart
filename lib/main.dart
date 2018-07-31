import 'package:rule_engine/fact.dart';
import 'package:rule_engine/rule.dart';
import 'package:rule_engine/rule_engine.dart';

import 'lexer.dart';
import 'parser.dart';

var test = r"""
      Expense( \$2: sum( amount ) < \$1 ) over Duration( {days: 7}, substract( {days: 7} ) )
      Expense( \$3: sum( amount ) < \$2 ) over Duration( {days: 7}, substract( {days: 14} ) )
      Expense( \$4: sum( amount ) < \$3 ) over Duration( {days: 7}, substract( {days: 21} ) )

""";
String code = r"""rule "weekly saver for bob"
  when
      SimpleFact( name == "Ewout", created in Window( length: Duration(seconds: 1110) ), $amount: amount )
  then
      insert Achievement( "weekly saver", "...", $amount )
end
""";

main() {
  Lexer lexer = new Lexer(code);
  var tokens = lexer.getTokenList();
  //tokens.forEach((e) => print(e) );

  Parser parser = new Parser(tokens);

  RuleEngine ruleEngine = new RuleEngine(parser.buildTree());

  ruleEngine.registerListener((type, arguments) {
    print("insert $type with arguments $arguments");
  });

  Fact fact = new SimpleFact("Ewout", 10, new DateTime(1996, 02, 19));
  ruleEngine.insertFact(fact);
  fact = new SimpleFact("Ewout", 120, new DateTime.now().subtract(new Duration(seconds: 100)));
  ruleEngine.insertFact(fact);
}

class SimpleFact extends Fact {
  String _name;
  int _amount;
  DateTime _created;

  SimpleFact(this._name, this._amount, this._created);

  @override
  Map<String, dynamic> attributeMap() {
    Map<String, dynamic> attributes = new Map<String, dynamic>();
    attributes["name"] = _name;
    attributes["amount"] = _amount;
    attributes["created"] = _created;
    return attributes;
  }

  @override
  String toString() {
    return "$_name: $_amount $_created";
  }
}
