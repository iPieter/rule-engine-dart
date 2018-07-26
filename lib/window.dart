class Window
{
  String start;
  String end;
  Map<String, String> durationArguments;

  Window()
  {
    start = "";
    end = "";
    durationArguments = new Map<String,String>();
  }

  String toString()
  {
    return "{Window: start:$start, end:$end, duration:$durationArguments }";
  }
}