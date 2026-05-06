abstract class Logger {
  String get name;
  String get icon;
  List<String> get logs;
  void log(String message);
  void clear();
}
