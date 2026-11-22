
class ApiConstants {
  static const String baseUrl = 'http://192.168.1.41:8080';

  static const String tasksEndpoint = '/api/v1/tasks/';

  static String get tasksUrl => '$baseUrl$tasksEndpoint';
  // Request timeout
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
