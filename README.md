# rule_engine

## Features

- Brings production rules with a drools-like syntax to Dart and Flutter
- Dynamic insertion and evaluation of facts
- Caches earlier matches of different rule clauses for better performance
- Works even with lack of reflection in Flutter
- Allows multiple callbacks for end results
- Supports variables inside rules

## Getting Started

Get started by adding the package to your project as a dependency:

```
dependencies:
 rule_engine:
   git: git://github.com/iPieter/rule_engine_dart
```

At the moment, only the git version is available, since it is not yet published.

## Rule syntax

This rule engine follows basically the same syntax as Drools, with some minor differences. It has the following boilerplate:

```
rule "<name>"
  when
      <clause>
      <clause>
      ...
      <clause>
  then
      <consequence>
end
```

A detailed overview of the syntax in BHNF and with railroad diagrams can be found in `syntax.xhtml`.

### Clause syntax

Each clause has a type and multiple attributes. All those have to match an object before the clause can be true.

```
SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
```

In the above case, there are 2 condition and one assignment in the clause. The first condition requires the `name` of an SimpleFact-object to be Bob. The second uses the `DateTime`-attribute `created` to assert if it was created in the last 31 days.

When those

## Example

Start by creating a new rule engine with a listener. The code attribute is a string, which can be predefined or read in from a file.

```dart
String code = r"""
rule "get amount for bob"
  when
      SimpleFact( name == "Bob", created in Window( length: Duration(days: 31) ), $amount: amount )
  then
      insert Achievement( "Bob saved some money", $amount )
end
""";

RuleEngine ruleEngine = new RuleEngine(code);

ruleEngine.registerListener((type, arguments) {
  print("insert $type with arguments $arguments");
});
```
