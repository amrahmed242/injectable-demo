/// A third-party class — no @injectable annotation.
/// We can't modify this source (imagine it's from a package).
class HttpService {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  const HttpService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Future<String> get(String path) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return '{\n'
        '  "status": 200,\n'
        '  "url": "$baseUrl$path",\n'
        '  "data": "Mock response payload",\n'
        '  "timestamp": "${DateTime.now().toIso8601String()}"\n'
        '}';
  }
}
