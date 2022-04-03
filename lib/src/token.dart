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
  final TokenType type;
  final String name;
  final int pos;

  const Token(this.type, this.name, this.pos);

  toString() {
    return "{$type:$name @ pos $pos}";
  }
}
