import 'package:injectable/injectable.dart';
import 'logger.dart';

@Named('remote')
@Injectable(as: Logger)
class RemoteLogger implements Logger {
  final List<String> _logs = [];

  @override
  String get name => 'RemoteLogger';

  @override
  String get icon => '☁️';

  @override
  List<String> get logs => List.unmodifiable(_logs);

  @override
  void log(String message) {
    _logs.add('[POST /logs] ${_ts()} "$message" → 200 OK');
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
