enum TokenType {
  LEFT_BRACKET,
  RIGHT_BRACKET,
  LEFT_PAREN,
  RIGHT_PAREN,
  IDENTIFIER,
  STRING,
  PLUS,
  MINUS,
  MULTIPLY,
  DIVIDE,
  EQUALS,
  LESS_THAN,
  GREATER_THAN,
  COLON,
  DOT,
  COMMA,
  INTEGER,
  FLOATING_POINT
}

class Token {
  TokenType _type;
  String _name;
  int _pos;

  Token(this._type, this._name, this._pos);

  toString() {
    return "{$_type:$_name @ pos $_pos}";
  }

  get type => _type;
  get name => _name;
  get pos => _pos;
}
