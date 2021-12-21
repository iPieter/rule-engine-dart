import 'token.dart';

class Lexer {
  final String _code;
  final Map<String, TokenType> _tokenTypeMap = {};
  int _pos = 0;

  Lexer(this._code) {
    _tokenTypeMap['('] = TokenType.LEFT_PAREN;
    _tokenTypeMap[')'] = TokenType.RIGHT_PAREN;
    _tokenTypeMap['{'] = TokenType.LEFT_BRACKET;
    _tokenTypeMap['}'] = TokenType.RIGHT_BRACKET;

    _tokenTypeMap['+'] = TokenType.PLUS;
    _tokenTypeMap['-'] = TokenType.MINUS;
    _tokenTypeMap['*'] = TokenType.MULTIPLY;
    _tokenTypeMap['/'] = TokenType.DIVIDE;

    _tokenTypeMap['='] = TokenType.EQUALS;
    _tokenTypeMap[':'] = TokenType.COLON;
    _tokenTypeMap['>'] = TokenType.GREATER_THAN;
    _tokenTypeMap['<'] = TokenType.LESS_THAN;
    _tokenTypeMap['.'] = TokenType.DOT;
    _tokenTypeMap[','] = TokenType.COMMA;
  }

  consumeChar() {
    if (_pos + 1 > _code.length)
      return '';
    else
      return _code[_pos++];
  }

  peekChar() {
    if (_pos + 1 > _code.length)
      return '';
    else
      return _code[_pos];
  }

  List<Token> getTokenList() {
    final result = <Token>[];

    RegExp whitespaceRegex = RegExp(r"\s");
    RegExp identifierRegex = RegExp(r"[a-zA-Z]");
    RegExp digitRegex = RegExp(r"\d");

    var c = '';
    while (_pos + 1 < _code.length) {
      c = consumeChar();
      switch (c) {
        case '':
          return result;
        case '"':
          var tokenName = "";
          final start = _pos - 1;
          while ((c = consumeChar()) != "\"") {
            tokenName += c;
          }
          result.add(Token(TokenType.STRING, tokenName, start));
          break;
        default:
          if (!whitespaceRegex.hasMatch(c)) {
            var tokenName = "" + c;
            final start = _pos - 1;

            if (c == '-' && digitRegex.hasMatch(peekChar())) {
              while (digitRegex.hasMatch(peekChar())) {
                tokenName += consumeChar();
              }
              if (peekChar() == '.') {
                tokenName += consumeChar();
                while (digitRegex.hasMatch(peekChar())) {
                  tokenName += consumeChar();
                }
                result.add(Token(TokenType.FLOATING_POINT, tokenName, start));
              } else {
                result.add(Token(TokenType.INTEGER, tokenName, start));
              }
              break;
            }

            if (_tokenTypeMap.containsKey(c)) {
              result.add(Token(_tokenTypeMap[c]!, c, _pos - 1));
              break;
            }

            if (digitRegex.hasMatch(c)) {
              while (digitRegex.hasMatch(peekChar())) {
                tokenName += consumeChar();
              }
              if (peekChar() == '.') {
                tokenName += consumeChar();
                while (digitRegex.hasMatch(peekChar())) {
                  tokenName += consumeChar();
                }
                result.add(Token(TokenType.FLOATING_POINT, tokenName, start));
              } else {
                result.add(Token(TokenType.INTEGER, tokenName, start));
              }
              break;
            }

            while (identifierRegex.hasMatch(peekChar())) {
              tokenName += consumeChar();
            }
            result.add(Token(TokenType.IDENTIFIER, tokenName, start));
          }
          break;
      }
    }
    return result;
  }
}
