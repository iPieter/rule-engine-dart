import 'token.dart';

class Lexer {
  int _pos;
  String _code;
  Map<String, TokenType> _tokenTypeMap;

  Lexer(this._code) {
    _pos = 0;
    _tokenTypeMap = new Map();
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
    var result = new List<Token>();

    RegExp whitespace = new RegExp(r"\s");
    RegExp identifier = new RegExp(r"\w");

    var c = '';
    while (_pos + 1 < _code.length) {
      c = consumeChar();

      if (_tokenTypeMap.containsKey(c))
        result.add(new Token(_tokenTypeMap[c], c, _pos - 1));
      else {
        switch (c) {
          case '':
            return result;
            break;
          case '"':
            var tokenName = "";
            var start = _pos - 1;
            while ((c = consumeChar()) != "\"") {
              tokenName += c;
            }
            result.add(new Token(TokenType.STRING, tokenName, start));
            break;
          default:
            if (!whitespace.hasMatch(c)) {
              var tokenName = "" + c;
              var start = _pos - 1;

              while ((c = peekChar()) != "\"" && identifier.hasMatch(c)) {
                tokenName += consumeChar();
              }
              result.add(new Token(TokenType.IDENTIFIER, tokenName, start));
            }
            break;
        }
      }
    }
    return result;
  }
}
