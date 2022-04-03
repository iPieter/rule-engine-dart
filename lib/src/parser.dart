import 'assignment.dart';
import 'clause.dart';
import 'condition.dart';
import 'consequence.dart';
import 'nodes/aggregate_node.dart';
import 'nodes/attribute_node.dart';
import 'nodes/comparison_node.dart';
import 'nodes/literal_node.dart';
import 'nodes/node.dart';
import 'nodes/symbol_node.dart';
import 'rule.dart';
import "token.dart";
import 'window.dart';

class Parser {
  final List<Token> _tokenList;
  final String _code;
  int _index = 0;

  Parser(this._tokenList, this._code);

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

    StringBuffer sb = StringBuffer();

    for (int i = 1; i < begin; i++) sb.write(" ");

    print("$sb∧");
    print("$sb#=== $error");

    throw Error();
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

  Assignment buildAssignment(Token clauseSubject) {
    Assignment assignment;

    assertToken(consumeToken(), TokenType.COLON);
    //rhs is either an attribute or an aggregate
    Token rhsToken = consumeToken();
    // finally, match the rhs
    Node rhs = buildConditionSide(rhsToken);

    SymbolNode symbolNode = SymbolNode(clauseSubject.name);
    assignment = Assignment(symbolNode, rhs);

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

      result = AggregateNode(clauseSubject.name, attributeToken.name);
    } else {
      // 3 cases left: literal, attribute or a symbol
      // symbol
      if (clauseSubject.name[0] == r"$")
        result = SymbolNode(clauseSubject.name);
      // literal
      else if ([TokenType.STRING, TokenType.INTEGER, TokenType.FLOATING_POINT]
          .contains(clauseSubject.type))
        result = LiteralNode(clauseSubject.name);
      else
        result = AttributeNode(clauseSubject.name);
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

      Window window = Window();

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

      result = Condition.fromWindow(lhs, window);
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
            ComparisonNode(firstComparison.name + secondComparison.name);
      } else {
        if (firstComparison.type == TokenType.EQUALS) {
          Token secondComparison = consumeToken();
          assertToken(secondComparison, TokenType.EQUALS);
          comparisonNode =
              ComparisonNode(firstComparison.name + secondComparison.name);
        } else {
          comparisonNode = ComparisonNode(firstComparison.name);
        }
      }
    }

    // finally, match the rhs
    Token rhsToken = consumeToken();
    rhs = buildConditionSide(rhsToken);

    result = Condition(lhs, comparisonNode, rhs);

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

    Clause result = Clause(typeToken.name, negated);

    lookahead = peekToken();

    if (lookahead.type != TokenType.RIGHT_PAREN)
      do {
        Token clauseSubject = consumeToken();

        Token ll = peekToken();
        if (ll.type == TokenType.COLON) {
          final assignment = buildAssignment(clauseSubject);
          //print(assignment.toString());
          result.addAssignment(assignment);
        } else {
          final condition = buildCondition(clauseSubject);
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
    result = Consequence(typeToken.name);
    assertToken(consumeToken(), TokenType.LEFT_PAREN);

    Token lookahead = peekToken();

    while (lookahead.type != TokenType.RIGHT_PAREN) {
      Token clauseSubject = consumeToken();
      Node? node;

      if (clauseSubject.name[0] == r"$")
        node = SymbolNode(clauseSubject.name);
      // literal
      else if ([TokenType.STRING, TokenType.INTEGER, TokenType.FLOATING_POINT]
          .contains(clauseSubject.type)) node = LiteralNode(clauseSubject.name);

      if (node != null) result.addArgument(node);

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
    Rule rule = Rule(nameToken.name);

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
    final result = <Rule>[];
    while (peekToken() != null) {
      final rule = buildRule();
      result.add(rule);
    }
    return result;
  }
}
