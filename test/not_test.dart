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
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(Expense("Bob", 1000, "Cheese", DateTime.now()));
  expect(results.length, equals(1));
  ruleEngine.insertFact(Achievement("01", "Bob saved some money", 100));

  ruleEngine.insertFact(Expense("Bob", 2000, "Cheese", DateTime.now()));
  expect(results.length, equals(1));
}

void _reverseBasicTest() {
  String code = r"""
rule "expense"
  when
    Expense( amount > 10, $amount: amount )
    not Achievement( title ==  "Bob saved some money" )
  then
    publish Achievement( "01", "Bob saved some money", $amount )
end
""";
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(Expense("Bob", 1000, "Cheese", DateTime.now()));
  expect(results.length, equals(1));
  ruleEngine.insertFact(Achievement("01", "Bob saved some money", 100));

  ruleEngine.insertFact(Expense("Bob", 2000, "Cheese", DateTime.now()));
  expect(results.length, equals(1));
}

void main() {
  test('Test not statement', _basicTest);
  test('Test not statement in reverse', _reverseBasicTest);
}

class Expense extends Fact {
  Map<String, dynamic> attributes = Map<String, dynamic>();

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
  Map<String, dynamic> attributes = Map<String, dynamic>();

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
