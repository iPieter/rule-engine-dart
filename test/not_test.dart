import 'package:rule_engine/src/fact.dart';
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void _basicTest() {
  String code = r"""
rule "expense"
  when
    not Achievement( title ==  "Bob saved some money" )
    Expense( amount > 10, $amount: amount )
  then
    publish Achievement( "01", "Bob saved some money", $amount )
end
""";
  var ruleEngine = new RuleEngine(code);

  var results = new List();
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(new Expense("Bob", 1000, "Cheese", new DateTime.now()));
  expect(results.length, equals(1));
  ruleEngine.insertFact(new Achievement("01", "Bob saved some money", 100));

  ruleEngine.insertFact(new Expense("Bob", 2000, "Cheese", new DateTime.now()));
  expect(results.length, equals(1));
}

void main() {
  test('Test not statement', _basicTest);
}

class Expense extends Fact {
  Map<String, dynamic> attributes = new Map<String, dynamic>();

  Expense(name, amount, category, created) {
    attributes["name"] = name;
    attributes["amount"] = amount;
    attributes["category"] = category;
    attributes["created"] = created;
  }

  @override
  Map<String, dynamic> attributeMap() {
    return attributes;
  }
}

class Achievement extends Fact {
  Map<String, dynamic> attributes = new Map<String, dynamic>();

  Achievement(badge, title, descr) {
    attributes["badge"] = badge;
    attributes["title"] = title;
    attributes["descr"] = descr;
  }

  @override
  Map<String, dynamic> attributeMap() {
    return attributes;
  }
}
