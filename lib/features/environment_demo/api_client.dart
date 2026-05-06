abstract class ApiClient {
  String get baseUrl;
  String get environmentLabel;
  Future<Map<String, dynamic>> fetchUser(String id);
}
