class ApiConfig {
  static const String baseUrl = String.fromEnvironment('baseURL');

  // For production, you might want to use environment variables
  // static const String baseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'http://localhost:3000/api',
  // );
}
