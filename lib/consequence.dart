class Consequence
{
  String _type;
  List<String> _arguments;

  Consequence(this._type)
  {
    _arguments = new List();
  }

  addArgument( String arg )
  {
    _arguments.add(arg);
  }
}