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

So each clause matches one type of fact, followed by zero or more conditions or assignments between the brackets. In short, the following elements are available:

- **Assignments**: the right hand side is assigned to a symbol, which starts with a `$`.

  ```
  SimpleFact( $amount: amount )
  ```

  In the above clause, the attribute `amount` is assigned to a symbol with name `$amount`.

- **Conditions**: both sides have to be comparable, and the condition should be true for the clause to finish.
  The environment supports equality for strings, numbers and objects and comparisons for numbers.

  ```
  SimpleFact( amount > 10 )
  ```

  The above clause matches all objects of type `SimpleFact` with an amount of more than 10 dollars/euros/turtles.

  ```
  SimpleFact( name == "Bob", $bobsSpending: amount )
  SimpleFact( amount > $bobsSpending )
  ```

  Conditions can support symbols as well, becoming available in sequential order.

- **Windows**: to support sliding windows, an `in`-operator is available for attributes of type `DateTime`. This window follows the dart syntax and supports a start and end date and a duration.

  ```
  SimpleFact( created in Window( length: Duration( days: 31 ) ) )
  ```

  This is the most simple syntax and takes a window starting 31 days ago and ending now. The length can be defined with a duration object, just like in dart.

  ```
  SimpleFact( created in Window( begin: "1969-07-20 00:00:00", length: Duration( days: 31 ) ) )
  SimpleFact( created in Window( end: "2018-07-20 23:59:59",length: Duration( days: 31 ) ) )
  ```

  As is seen in the above example, both begin and end times can be specified. Currently, this is as a string that can be parsed by dart's `DateTime` constructor. Future work is to provide the entire dateTime-api, but feel free to fork it. ;-)

- **Aggregates**: when multiple facts match one clause, these can be combined to one evaluation. The result can be used as a regular condition, or an assignment. Inside the aggregate, only attributes are allowed.
  ```
  SimpleFact( sum( amount ) > 1000 )
  ```
  This will evaluate to true if the sum of all matching facts is over 1000. In addition to the `sum()` operation, ~~`min()`, `max()`~~ _(not yet implemented)_ and `average()` are available as well.

### Consequence syntax

Consequences are either inserted as new facts, allowing rules to generate additional facts, or published to a listener.

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
