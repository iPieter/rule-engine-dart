class Consequence {
  String _type;
  List<String> _arguments;

  Consequence(this._type) {
    _arguments = new List();
  }

  String getType() {
    return _type;
  }

  List<String> getArguments() {
    return _arguments;
  }

  addArgument(String arg) {
    _arguments.add(arg);
  }
}
