import 'dart:math';

import 'package:rule_engine/rule_engine.dart';

String code1 = r"""rule "get amount for bob"
  when
      not SimpleFact( name == "Bob", $name: name )
  then
      publish Achievement( "Bob saved some money", $amount )
end
""";
String code2 = r"""rule "1"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "2"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
      SimpleFact( name == "Jef", amount > 100)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "3"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
      SimpleFact( name == "Jef", amount > 200)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "4"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
      SimpleFact( name == "Jef", amount > 200)
      SimpleFact( name == "Ewout", amount == 0)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "5"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
      SimpleFact( name == "Jef", amount > 200)
      SimpleFact( name == "Bobbie", amount > $amount)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "6"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
      SimpleFact( name == "Jef", amount > $amount)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "7"
  when
      SimpleFact( name == "Isisdorius", amount > 10000)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "8"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
      SimpleFact( name == "Jef", amount < $amount)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "9"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
      SimpleFact( name == "Jef", amount > $amount)
      SimpleFact( name == "Bobbie", amount > $amount)
      SimpleFact( name == "Jos", amount > $amount)
  then
      publish Achievement( "Bob saved some money", $amount )
end

rule "10"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ) )
      SimpleFact( name == "Jef", amount == 10)
  then
      publish Achievement( "Bob saved some money", $amount )
end
""";

String code3 = r"""
rule "First Expense"
  when
    not Achievement( title == $ruleName )
    Expense()
  then
    publish Achievement( "01", $ruleName, "The beginning of a new era" )
end

rule "Sober Monkey"
  when
    not Achievement( title == $ruleName )
    not Expense( category == "Alcohol", when in Window( length: Duration( days: 2 ) ) )
  then
    publish Achievement( "02", $ruleName, "No booze for a month" )
end""";

main() {
  for (final code in [code3]) {
    print(code.substring(0, 20));

    for (var j = 0; j < 8; j++) {
      RuleEngine ruleEngine = RuleEngine(code);

      ruleEngine.registerListener((type, arguments) {
        //print("insert $type with arguments $arguments");
      });

      final begin = DateTime.now();

      Fact fact = SimpleFact("Ewout", 10, DateTime(1996, 02, 19));
      ruleEngine.insertFact(fact);

      for (var i = 0; i < pow(10, j); i++) {
        fact = SimpleFact(
          "Ewout",
          120,
          DateTime.now().subtract(Duration(seconds: 100)),
        );
        ruleEngine.insertFact(fact);
      }

      final end = DateTime.now();
      print("$j;${end.difference(begin)}");
    }
  }
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
