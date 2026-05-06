import 'package:injectable/injectable.dart';

@singleton
class AppStateService {
  final String instanceId;
  final DateTime createdAt;
  int _sessionCount = 0;

  AppStateService()
      : instanceId = DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase().substring(4),
        createdAt = DateTime.now();

  int get sessionCount => _sessionCount;
  void increment() => _sessionCount++;
  void reset() => _sessionCount = 0;
}
