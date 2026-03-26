abstract class ApiService {
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? data});
  Future<Map<String, dynamic>> get(String endpoint);
  // Add other methods as needed
}