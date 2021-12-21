import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void _basicTest() {
  String code = r"""
rule "weekly saver"
  when
      SimpleFact( amount > 10 )
  then
      publish Achievement( "test" )
end
""";
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(t);
  });

  ruleEngine.insertFact(SimpleFact("Bob", 11, DateTime.now()));
  expect(results.length, equals(1));

  ruleEngine.insertFact(SimpleFact("Bob", 12, DateTime.now()));
  expect(results.length, equals(2));
}

void _minTest() {
  String code = r"""
rule "weekly saver"
  when
      SimpleFact( name == "Bob", $value: min( amount ) )
  then
      publish Test( $value )
end
""";
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(SimpleFact("Bob", 11, DateTime.now()));
  expect(num.tryParse(results[0]), equals(11));

  ruleEngine.insertFact(SimpleFact("Bob", 12, DateTime.now()));
  expect(num.tryParse(results[1]), equals(11));
}

void _maxTest() {
  String code = r"""
rule "weekly saver"
  when
      SimpleFact( name == "Bob", $value: max( amount ) )
  then
      publish Test( $value )
end
""";
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(SimpleFact("Bob", 11, DateTime.now()));
  expect(num.tryParse(results[0]), equals(11));

  ruleEngine.insertFact(SimpleFact("Bob", 12, DateTime.now()));
  expect(num.tryParse(results[1]), equals(12));
}

void _sumTest() {
  String code = r"""
rule "weekly saver"
  when
      SimpleFact( name == "Bob", $value: sum( amount ) )
  then
      publish Test( $value )
end
""";
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(SimpleFact("Bob", 10, DateTime.now()));
  expect(num.tryParse(results[0]), equals(10));

  ruleEngine.insertFact(SimpleFact("Bob", 12, DateTime.now()));
  expect(num.tryParse(results[1]), equals(22));
}

void _noSumTest() {
  String code = r"""
rule "weekly saver"
  when
      SimpleFact( name == "Bob", $value: sum( amount ) )
  then
      publish Test( $value )
end
""";
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(SimpleFact("Bob", 10, DateTime.now()));
  expect(num.tryParse(results[0]), equals(10));

  //shouldn't emit a fact
  ruleEngine.insertFact(SimpleFact("Jef", 12, DateTime.now()));
  expect(num.tryParse(results[0]), equals(10));

  ruleEngine.insertFact(SimpleFact("Bob", 20, DateTime.now()));
  expect(num.tryParse(results[1]), equals(30));

  ruleEngine.insertFact(SimpleFact("Bob", 30, DateTime.now()));
  expect(num.tryParse(results[2]), equals(60));

  ruleEngine.insertFact(SimpleFact("Bob", 40, DateTime.now()));
  expect(num.tryParse(results[3]), equals(100));
}

void _averageTest() {
  String code = r"""
rule "weekly saver"
  when
      SimpleFact( name == "Bob", $value: average( amount ) )
  then
      publish Test( $value )
end
""";
  final ruleEngine = RuleEngine(code);

  final results = [];
  ruleEngine.registerListener((t, a) {
    results.add(a[0]);
  });

  ruleEngine.insertFact(SimpleFact("Bob", 10, DateTime.now()));
  expect(num.tryParse(results[0]), equals(10));

  ruleEngine.insertFact(SimpleFact("Bob", 20, DateTime.now()));
  expect(num.tryParse(results[1]), equals(15));
}

void main() {
  test('Basic test: insertion of facts', _basicTest);
  test('Testing of min-aggregate', _minTest);
  test('Testing of max-aggregate', _maxTest);
  test('Testing of sum-aggregate', _sumTest);
  test('Testing of average-aggregate', _averageTest);
  test('Testing of sum-aggregate with non-matching facts', _noSumTest);
}

class SimpleFact extends Fact {
  String _name;
  int _amount;
  DateTime _created;

  SimpleFact(this._name, this._amount, this._created);

  @override
  Map<String, dynamic> attributeMap() {
    Map<String, dynamic> attributes = Map<String, dynamic>();
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
