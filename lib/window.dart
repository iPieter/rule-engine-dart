class Window {
  String start;
  String end;
  Map<String, String> durationArguments;

  DateTime _beginTime;
  DateTime _endTime;

  Window() {
    start = "";
    end = "";
    durationArguments = new Map<String, String>();
  }

  bool contains(DateTime moment) {
    if (_beginTime == null || _endTime == null) _parseTime();

    return moment.isAfter(_beginTime) && moment.isBefore(_endTime);
  }

  /// Internal function to parse the provided arguments of a [Window].
  void _parseTime() {
    if (start != "") {
      _beginTime = DateTime.parse(start);
    }

    if (end != "") {
      _endTime = DateTime.parse(end);
    }
  }

  String toString() {
    return "{Window: start:$start, end:$end, duration:$durationArguments }";
  }
}
