class Window {
  final Map<String, String> durationArguments = {};
  String start = '';
  String end = '';
  DateTime? _beginTime;
  DateTime? _endTime;

  bool contains(DateTime moment) {
    if (_beginTime == null || _endTime == null) _parseTime();

    return moment.isAfter(_beginTime!) && moment.isBefore(_endTime!);
  }

  /// Internal function to parse the provided arguments of a [Window].
  void _parseTime() {
    if (start != "") {
      _beginTime = DateTime.parse(start);
    }

    if (end != "") {
      _endTime = DateTime.parse(end);
    }

    Duration duration = Duration(
      days: int.parse(durationArguments["days"] ?? "0"),
      hours: int.parse(durationArguments["hours"] ?? "0"),
      minutes: int.parse(durationArguments["minutes"] ?? "0"),
      seconds: int.parse(durationArguments["seconds"] ?? "0"),
      milliseconds: int.parse(durationArguments["milliseconds"] ?? "0"),
      microseconds: int.parse(durationArguments["microseconds"] ?? "0"),
    );

    if (_beginTime == null && _endTime == null) {
      _endTime = DateTime.now();
    }

    if (_beginTime == null) _beginTime = _endTime?.subtract(duration);

    if (_endTime == null) _endTime = _beginTime?.add(duration);
  }

  String toString() {
    return "{Window: start:$start, end:$end, duration:$durationArguments }";
  }
}
