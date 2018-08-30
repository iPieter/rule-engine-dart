import "token.dart";
import 'rule.dart';
import 'clause.dart';
import 'assignment.dart';
import 'condition.dart';
import 'consequence.dart';
import 'window.dart';
import 'nodes/node.dart';
import 'nodes/aggregate_node.dart';
import 'nodes/symbol_node.dart';
import 'nodes/attribute_node.dart';
import 'nodes/literal_node.dart';
import 'nodes/comparison_node.dart';

class Parser {
  List<Token> _tokenList;
  int _index;
  bool _valid;

  Parser(this._tokenList) {
    _index = 0;
    _valid = true;
  }

  consumeToken() {
    if (_index + 1 > _tokenList.length)
      return null;
    else
      return _tokenList[_index++];
  }

  peekToken() {
    if (_index + 1 > _tokenList.length)
      return null;
    else
      return _tokenList[_index];
  }

  assertToken(Token token, TokenType type, {String value: ""}) {
    if (token.type != type) {
      exitWithError(
          "Error while parsing, expected '${type}', got '${token.type}' for token: '${token}'");
    }
    if (value != "") {
      if (token.name != value) {
        exitWithError(
            "Error while parsing, expected token of value '${value}', got '${token.name}' for token: '${token}'");
      }
    }
    return true;
  }

  exitWithError(String error) {
    print(error);
    throw new Error();
  }

  assertTokenList(Token token, List<TokenType> types, {String value: ""}) {
    bool match = false;
    for (var i = 0; i < types.length; i++)
      match = match || token.type == types[i];

    if (!match) {
      exitWithError(
          "Error while parsing, expected ${types.toString()}, got '${token.type}' for token: '${token}'");
    }
    if (value != "") {
      if (token.name != value) {
        exitWithError(
            "Error while parsing, expected '${value}', got '${token.name}' for token: '${token}'");
      }
    }
    return true;
  }

  Assignment buildAssignment(Token clauseSubject) {
    Assignment assignment;

    assertToken(consumeToken(), TokenType.COLON);
    //rhs is either an attribute or an aggregate
    Token rhsToken = consumeToken();
    // finally, match the rhs
    Node rhs = buildConditionSide(rhsToken);

    SymbolNode symbolNode = new SymbolNode(clauseSubject.name);
    assignment = new Assignment(symbolNode, rhs);

    return assignment;
  }

  Node buildConditionSide(Token clauseSubject) {
    Node result;
    Token lookahead = peekToken();
    // 4 cases, 1st one: aggregate
    if (lookahead.type == TokenType.LEFT_PAREN) {
      assertToken(consumeToken(), TokenType.LEFT_PAREN);
      Token attributeToken = consumeToken();
      assertToken(attributeToken, TokenType.IDENTIFIER);
      assertToken(consumeToken(), TokenType.RIGHT_PAREN);

      result = new AggregateNode(clauseSubject.name, attributeToken.name);
    } else {
      RegExp numberRegExp = new RegExp(r"[0-9]+");
      // 3 cases left: literal, attribute or a symbol
      // symbol
      if (clauseSubject.name[0] == r"$")
        result = new SymbolNode(clauseSubject.name);
      // literal
      else if (clauseSubject.type == TokenType.STRING ||
          numberRegExp.stringMatch(clauseSubject.name) == clauseSubject.name)
        result = new LiteralNode(clauseSubject.name);
      else
        result = new AttributeNode(clauseSubject.name);
    }
    return result;
  }

  Condition buildCondition(Token clauseSubject) {
    Condition result;
    Node lhs;
    ComparisonNode comparisonNode;
    Node rhs;

    // match lhs of the comparison
    lhs = buildConditionSide(clauseSubject);

    // match the comparison operator itself
    Token firstComparison = consumeToken();

    if (firstComparison.name == "in") {
      assertToken(firstComparison, TokenType.IDENTIFIER, value: "in");

      assertToken(consumeToken(), TokenType.IDENTIFIER, value: "Window");
      assertToken(consumeToken(), TokenType.LEFT_PAREN);

      var lookahead = peekToken();

      Window window = new Window();

      while (lookahead.type != TokenType.RIGHT_PAREN) {
        Token t = consumeToken();
        if (t.name == "end" || t.name == "start") {
          assertToken(consumeToken(), TokenType.COLON);
          Token dateStringToken = consumeToken();
          assertToken(dateStringToken, TokenType.STRING);

          if (t.name == "start") {
            if (window.start != "")
              exitWithError("Window contains more than 2 start declarations");

            window.start = dateStringToken.name;
          }
          if (t.name == "end") {
            if (window.end != "")
              exitWithError("Window contains more than 2 end declarations");

            window.end = dateStringToken.name;
          }
        } else {
          assertToken(t, TokenType.IDENTIFIER, value: "length");
          assertToken(consumeToken(), TokenType.COLON);

          Token lengthCheckToken = consumeToken();
          if (lengthCheckToken.name == "Duration") {
            assertToken(lengthCheckToken, TokenType.IDENTIFIER,
                value: "Duration");
            assertToken(consumeToken(), TokenType.LEFT_PAREN);

            Token ll = peekToken();
            while (ll.type != TokenType.RIGHT_PAREN) {
              Token n = consumeToken();
              assertToken(n, TokenType.IDENTIFIER);
              assertToken(consumeToken(), TokenType.COLON);
              Token v = consumeToken();
              assertToken(v, TokenType.IDENTIFIER);

              window.durationArguments[n.name] = v.name;
              ll = peekToken();
            }
            assertToken(consumeToken(), TokenType.RIGHT_PAREN);
          } else {
            window.durationArguments["cardinal"] = lengthCheckToken.name;
          }
        }
        lookahead = peekToken();
        if (lookahead.type == TokenType.COMMA)
          assertToken(consumeToken(), TokenType.COMMA);
        lookahead = peekToken();
      }

      result = new Condition.fromWindow(lhs, window);
      assertToken(consumeToken(), TokenType.RIGHT_PAREN);

      return result;
    } else {
      assertTokenList(firstComparison,
          [TokenType.LESS_THAN, TokenType.GREATER_THAN, TokenType.EQUALS]);
      Token lookahead = peekToken();
      if (lookahead.type == TokenType.EQUALS) {
        Token secondComparison = consumeToken();
        assertToken(secondComparison, TokenType.EQUALS);
        comparisonNode =
            new ComparisonNode(firstComparison.name + secondComparison.name);
      } else {
        if (firstComparison.type == TokenType.EQUALS) {
          Token secondComparison = consumeToken();
          assertToken(secondComparison, TokenType.EQUALS);
          comparisonNode =
              new ComparisonNode(firstComparison.name + secondComparison.name);
        } else {
          comparisonNode = new ComparisonNode(firstComparison.name);
        }
      }
    }

    // finally, match the rhs
    Token rhsToken = consumeToken();
    rhs = buildConditionSide(rhsToken);

    result = new Condition(lhs, comparisonNode, rhs);

    return result;
  }

  Clause buildClause() {
    Token lookahead = peekToken();
    bool negated = false;
    if (lookahead.type == TokenType.IDENTIFIER && lookahead.name == "not") {
      assertToken(consumeToken(), TokenType.IDENTIFIER);
      negated = true;
    }

    Token typeToken;
    assertToken(typeToken = consumeToken(), TokenType.IDENTIFIER);
    assertToken(consumeToken(), TokenType.LEFT_PAREN);

    Clause result = new Clause(typeToken.name, negated);

    Token clauseSubject = consumeToken();

    lookahead = peekToken();
    if (lookahead.type == TokenType.COLON) {
      var assignment = buildAssignment(clauseSubject);
      //print(assignment.toString());
      result.addAssignment(assignment);
    } else {
      var condition = buildCondition(clauseSubject);
      //print(condition.toString());
      result.addCondition(condition);
    }

    lookahead = peekToken();
    while (lookahead.type == TokenType.COMMA) {
      assertToken(consumeToken(), TokenType.COMMA);

      Token clauseSubject = consumeToken();

      Token ll = peekToken();
      if (ll.type == TokenType.COLON) {
        var assignment = buildAssignment(clauseSubject);
        //print(assignment.toString());
        result.addAssignment(assignment);
      } else {
        var condition = buildCondition(clauseSubject);
        //print(condition.toString());
        result.addCondition(condition);
      }
      lookahead = peekToken();
    }

    assertToken(consumeToken(), TokenType.RIGHT_PAREN);

    lookahead = peekToken();

    return result;
  }

  Consequence buildConsequence() {
    Consequence result;
    assertToken(consumeToken(), TokenType.IDENTIFIER, value: "publish");

    Token typeToken = consumeToken();
    assertToken(typeToken, TokenType.IDENTIFIER);
    result = new Consequence(typeToken.name);
    assertToken(consumeToken(), TokenType.LEFT_PAREN);

    Token lookahead = peekToken();

    while (lookahead.type != TokenType.RIGHT_PAREN) {
      Token clauseSubject = consumeToken();
      Node node;
      RegExp numberRegExp = new RegExp(r"[0-9]+");

      if (clauseSubject.name[0] == r"$")
        node = new SymbolNode(clauseSubject.name);
      // literal
      else if (clauseSubject.type == TokenType.STRING ||
          numberRegExp.stringMatch(clauseSubject.name) == clauseSubject.name)
        node = new LiteralNode(clauseSubject.name);
      result.addArgument(node);

      lookahead = peekToken();
      if (lookahead.type == TokenType.COMMA)
        assertToken(consumeToken(), TokenType.COMMA);

      lookahead = peekToken();
    }

    assertToken(consumeToken(), TokenType.RIGHT_PAREN);

    return result;
  }

  Rule buildRule() {
    assertToken(consumeToken(), TokenType.IDENTIFIER, value: "rule");

    Token nameToken = consumeToken();
    assertToken(nameToken, TokenType.STRING);
    Rule rule = new Rule(nameToken.name);

    assertToken(consumeToken(), TokenType.IDENTIFIER, value: "when");

    Token t = peekToken();
    while (t.name != "then") {
      Clause c = buildClause();
      rule.addClause(c);

      t = peekToken();
    }

    assertToken(consumeToken(), TokenType.IDENTIFIER, value: "then");
    Consequence consequence = buildConsequence();

    rule.consequence = consequence;

    assertToken(consumeToken(), TokenType.IDENTIFIER, value: "end");

    return rule;
  }

  List<Rule> buildTree() {
    var result = new List<Rule>();
    while (peekToken() != null && _valid) {
      var rule = buildRule();
      if (rule != null) result.add(rule);
    }
    return result;
  }
}
