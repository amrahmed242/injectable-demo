import 'dart:math';
import 'package:injectable/injectable.dart';

@injectable
class CounterService {
  final String instanceId;
  final DateTime createdAt;
  int _count = 0;

  CounterService()
      : instanceId = _randomId(),
        createdAt = DateTime.now();

  static String _randomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  int get count => _count;
  void increment() => _count++;
  void decrement() {
    if (_count > 0) _count--;
  }
}
