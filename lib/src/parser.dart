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
import 'nodes/arithmetic_node.dart';

class Parser {
  List<Token> _tokenList;
  int _index;
  bool _valid;
  String _code;

  Parser(this._tokenList, this._code) {
    _index = 0;
    _valid = true;
  }

  consumeToken() {
    if (_index + 1 > _tokenList.length)
      return null;
    else
      return _tokenList[_index++];
  }

  peekToken({int amount: 0}) {
    if (_index + amount >= _tokenList.length)
      return null;
    else
      return _tokenList[_index + amount];
  }

  assertToken(Token token, TokenType type, {String value: ""}) {
    if (token.type != type) {
      exitWithError(
          "Error while parsing, expected '${type}', got '${token.type}' for token: '${token}'",
          token);
    }
    if (value != "") {
      if (token.name != value) {
        exitWithError(
            "Error while parsing, expected token of value '${value}', got '${token.name}' for token: '${token}'",
            token);
      }
    }
    return true;
  }

  exitWithError(String error, Token position) {
    int begin = 0;
    while (position.pos - begin > 0 &&
        _code.codeUnitAt(position.pos - begin) != '\n'.codeUnitAt(0)) begin++;

    int end = 0;
    while (position.pos + end < _code.length &&
        _code.codeUnitAt(position.pos + end) != '\n'.codeUnitAt(0)) end++;

    print(_code.substring(position.pos - begin, position.pos + end));

    StringBuffer sb = new StringBuffer();

    for (int i = 1; i < begin; i++) sb.write(" ");

    print("$sb∧");
    print("$sb#=== $error");

    throw new Error();
  }

  assertTokenList(Token token, List<TokenType> types, {String value: ""}) {
    bool match = false;
    for (var i = 0; i < types.length; i++)
      match = match || token.type == types[i];

    if (!match) {
      exitWithError(
          "Error while parsing, expected ${types.toString()}, got '${token.type}' for token: '${token}'",
          token);
    }
    if (value != "") {
      if (token.name != value) {
        exitWithError(
            "Error while parsing, expected '${value}', got '${token.name}' for token: '${token}'",
            token);
      }
    }
    return true;
  }

  Assignment buildAssignment() {
    Assignment assignment;

    Token clauseSubject = consumeToken();
    assertToken(clauseSubject, TokenType.IDENTIFIER);

    assertToken(consumeToken(), TokenType.COLON);
    //rhs is either an attribute or an aggregate
    // finally, match the rhs
    Node rhs = buildExpression();

    SymbolNode symbolNode = new SymbolNode(clauseSubject.name);
    assignment = new Assignment(symbolNode, rhs);

    return assignment;
  }

  Node buildExpression() {
    ArithmeticNode result;

    Node term = buildTerm();
    result = new ArithmeticNode(term);

    Token lookahead = peekToken();
    while ([TokenType.PLUS, TokenType.MINUS].contains(lookahead.type)) {
      Token operation = consumeToken();
      assertTokenList(operation, [TokenType.PLUS, TokenType.MINUS]);
      Node term = buildTerm();

      result.addOperation(operation.name, term);
      lookahead = peekToken();
    }

    return result;
  }

  Node buildTerm() {
    ArithmeticNode result;

    Node factor = buildFactor();
    result = new ArithmeticNode(factor);

    Token lookahead = peekToken();
    while ([TokenType.MULTIPLY, TokenType.DIVIDE].contains(lookahead.type)) {
      Token operation = consumeToken();
      assertTokenList(operation, [TokenType.MULTIPLY, TokenType.DIVIDE]);
      Node factor = buildFactor();
      result.addOperation(operation.name, factor);
      lookahead = peekToken();
    }

    return result;
  }

  Node buildFactor() {
    Node result;

    Token lookahead = peekToken();
    if (lookahead.type == TokenType.LEFT_PAREN) {
      assertToken(consumeToken(), TokenType.LEFT_PAREN);
      result = buildExpression();
      assertToken(consumeToken(), TokenType.RIGHT_PAREN);
    } else {
      result = buildConditionSide();
    }

    return result;
  }

  Node buildConditionSide() {
    Token clauseSubject = consumeToken();

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
      // 3 cases left: literal, attribute or a symbol
      // symbol
      if (clauseSubject.name[0] == r"$")
        result = new SymbolNode(clauseSubject.name);
      // literal
      else if ([TokenType.STRING, TokenType.INTEGER, TokenType.FLOATING_POINT]
          .contains(clauseSubject.type))
        result = new LiteralNode(clauseSubject.name);
      else
        result = new AttributeNode(clauseSubject.name);
    }
    return result;
  }

  Condition buildCondition() {
    Condition result;
    Node lhs;
    ComparisonNode comparisonNode;
    Node rhs;

    // match lhs of the comparison
    lhs = buildExpression();

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
              exitWithError(
                  "Window contains more than 2 start declarations", t);

            window.start = dateStringToken.name;
          }
          if (t.name == "end") {
            if (window.end != "")
              exitWithError("Window contains more than 2 end declarations", t);

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
              assertTokenList(v, [TokenType.INTEGER, TokenType.FLOATING_POINT]);

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
    rhs = buildExpression();

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

    lookahead = peekToken();

    if (lookahead.type != TokenType.RIGHT_PAREN)
      do {
        //Token clauseSubject = consumeToken();

        Token ll = peekToken(amount: 1);
        if (ll.type == TokenType.COLON) {
          var assignment = buildAssignment();
          //print(assignment.toString());
          result.addAssignment(assignment);
        } else {
          var condition = buildCondition();
          //print(condition.toString());
          result.addCondition(condition);
        }
        lookahead = peekToken();
      } while (lookahead.type == TokenType.COMMA &&
          assertToken(consumeToken(), TokenType.COMMA));

    assertToken(consumeToken(), TokenType.RIGHT_PAREN);

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

      if (clauseSubject.name[0] == r"$")
        node = new SymbolNode(clauseSubject.name);
      // literal
      else if ([TokenType.STRING, TokenType.INTEGER, TokenType.FLOATING_POINT]
          .contains(clauseSubject.type))
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
