import 'package:injectable/injectable.dart';
import 'api_client.dart';

@dev
@Injectable(as: ApiClient)
class DevApiClient implements ApiClient {
  @override
  String get baseUrl => 'https://dev-api.example.com';

  @override
  String get environmentLabel => 'Development';

  @override
  Future<Map<String, dynamic>> fetchUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'id': id,
      'name': 'Alice Dev',
      'email': 'alice@dev.example.com',
      'role': 'admin',
      'debug': true,
      'baseUrl': baseUrl,
    };
  }
}
