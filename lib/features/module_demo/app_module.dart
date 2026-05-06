import 'package:injectable/injectable.dart';
import 'http_service.dart';

@module
class AppModule {
  @singleton
  HttpService get httpService => const HttpService(
        baseUrl: 'https://api.myapp.com',
        timeout: Duration(seconds: 15),
        defaultHeaders: {
          'Content-Type': 'application/json',
          'X-App-Version': '1.0.0',
        },
      );
}
