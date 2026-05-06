import 'package:injectable/injectable.dart';
import 'logger.dart';

@Named('console')
@Injectable(as: Logger)
class ConsoleLogger implements Logger {
  final List<String> _logs = [];

  @override
  String get name => 'ConsoleLogger';

  @override
  String get icon => '🖥️';

  @override
  List<String> get logs => List.unmodifiable(_logs);

  @override
  void log(String message) {
    _logs.add('[stdout] ${_ts()} $message');
  }

  @override
  void clear() => _logs.clear();

  static String _ts() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }
}
