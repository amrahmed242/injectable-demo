import 'package:injectable/injectable.dart';
import 'api_client.dart';

@prod
@Injectable(as: ApiClient)
class ProdApiClient implements ApiClient {
  @override
  String get baseUrl => 'https://api.example.com';

  @override
  String get environmentLabel => 'Production';

  @override
  Future<Map<String, dynamic>> fetchUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': id,
      'name': 'Alice Smith',
      'email': 'alice@example.com',
      'role': 'user',
      'debug': false,
      'baseUrl': baseUrl,
    };
  }
}
