import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyticsService {
  final DateTime initializedAt;
  final List<String> _events = [];

  AnalyticsService() : initializedAt = DateTime.now();

  List<String> get events => List.unmodifiable(_events);

  void track(String event) {
    _events.add('$event  •  ${_fmt(DateTime.now())}');
  }

  void clear() => _events.clear();

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}.'
      '${dt.millisecond.toString().padLeft(3, '0')}';
}
