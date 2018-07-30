import 'lexer.dart';
import 'parser.dart';

var test = """
      Expense( \$2: sum( amount ) < \$1 ) over Duration( {days: 7}, substract( {days: 7} ) )
      Expense( \$3: sum( amount ) < \$2 ) over Duration( {days: 7}, substract( {days: 14} ) )
      Expense( \$4: sum( amount ) < \$3 ) over Duration( {days: 7}, substract( {days: 21} ) )
""";
String code = r"""
rule "weekly saver"
  when
      Expense( $1 : sum( amount ), 20 < amount ) over Window( start : "1969-07-20 00:00:00", length : Duration(days:2) )
  then
      insert Achievement( "weekly saver", "...", Badges.2 )
end
""";

main()
{
  Lexer lexer = new Lexer(code);
  var tokens = lexer.getTokenList();
  //tokens.forEach((e) => print(e) );

  Parser parser = new Parser(tokens);
  parser.buildTree();
}
