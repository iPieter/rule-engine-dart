import 'package:rule_engine/src/fact.dart';
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void _basicAddTest() {
  String code = r"""
rule "Bob saved some money"
  when
    Expense( $amount: amount + 10 )
  then
    publish Achievement( "01", $ruleName, $amount )
end
""";
  var ruleEngine = new RuleEngine(code);

  var results = new List();
  ruleEngine.registerListener((t, a) {
    if (t == "Achievement") results.add(new Achievement(a[0], a[1], a[2]));
  });

  ruleEngine.insertFact(new Expense("Bob", 1000, "Cheese", new DateTime.now()));
  expect(results.length, equals(1));
  expect(results[0].attributeMap()["title"], "Bob saved some money");
  expect(results[0].attributeMap()["descr"], "1010");
}

void _basicSubTest() {
  String code = r"""
rule "Bob saved some money"
  when
    Expense( $amount: amount - 100 )
  then
    publish Achievement( "01", $ruleName, $amount )
end
""";
  var ruleEngine = new RuleEngine(code);

  var results = new List();
  ruleEngine.registerListener((t, a) {
    if (t == "Achievement") results.add(new Achievement(a[0], a[1], a[2]));
  });

  ruleEngine.insertFact(new Expense("Bob", 1000, "Cheese", new DateTime.now()));
  expect(results.length, equals(1));
  expect(results[0].attributeMap()["title"], "Bob saved some money");
  expect(results[0].attributeMap()["descr"], "900");
}

void _basicMulTest() {
  String code = r"""
rule "Bob saved some money"
  when
    Expense( $amount: amount * 1.5 )
  then
    publish Achievement( "01", $ruleName, $amount )
end
""";
  var ruleEngine = new RuleEngine(code);

  var results = new List();
  ruleEngine.registerListener((t, a) {
    if (t == "Achievement") results.add(new Achievement(a[0], a[1], a[2]));
  });

  ruleEngine.insertFact(new Expense("Bob", 1000, "Cheese", new DateTime.now()));
  expect(results.length, equals(1));
  expect(results[0].attributeMap()["title"], "Bob saved some money");
  expect(results[0].attributeMap()["descr"], "1500.0");
}

void _basicDivTest() {
  String code = r"""
rule "Bob saved some money"
  when
    Expense( $amount: amount / 2 )
  then
    publish Achievement( "01", $ruleName, $amount )
end
""";
  var ruleEngine = new RuleEngine(code);

  var results = new List();
  ruleEngine.registerListener((t, a) {
    if (t == "Achievement") results.add(new Achievement(a[0], a[1], a[2]));
  });

  ruleEngine.insertFact(new Expense("Bob", 1000, "Cheese", new DateTime.now()));
  expect(results.length, equals(1));
  expect(results[0].attributeMap()["title"], "Bob saved some money");
  expect(results[0].attributeMap()["descr"], "500.0");
}

void _complexTest() {
  String code = r"""
rule "Bob saved some money"
  when
    Expense( name == "Jane" )
    Expense( name == "Bob", $amount: amount - 450 )
  then
    publish Achievement( 10, $ruleName, $amount )
end
""";
  var ruleEngine = new RuleEngine(code);

  var results = new List();
  ruleEngine.registerListener((t, a) {
    if (t == "Achievement") results.add(new Achievement(a[0], a[1], a[2]));
  });

  ruleEngine.insertFact(new Expense("Jane", 10, "Cheese", new DateTime.now()));
  expect(results.length, equals(0));
  ruleEngine.insertFact(new Expense("Bob", 1000, "Cheese", new DateTime.now()));
  expect(results.length, equals(1));
  expect(results[0].attributeMap()["title"], "Bob saved some money");
  expect(results[0].attributeMap()["descr"], "550.0");
}

void main() {
  test('Addition for symbol value', _basicAddTest);
  test('Subtraction for symbol value', _basicSubTest);
  test('Multiplication for symbol value', _basicMulTest);
  test('Division for symbol value', _basicDivTest);
  //test('Complex for symbol value', _complexTest);
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

  Achievement(value, title, descr) {
    attributes["value"] = value;
    attributes["title"] = title;
    attributes["descr"] = descr;
  }

  @override
  Map<String, dynamic> attributeMap() {
    return attributes;
  }
}
