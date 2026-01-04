
class ApiEndpoints {
  
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  
  // Health endpoints
  static const String saveHealthData = '/health/data';
  static const String getHealthData = '/health/data'; // GET request
  static const String getHealthHistory = '/health/history';
  static const String downloadHealthHistoryPdf = '/health/history/download';
  
  // Artikel endpoints
  static const String articles = '/articles';
  static const String articleDetail = '/articles'; // + /{id}
  
  // Edukasi endpoints
  static const String educations = '/educations';
  static const String educationDetail = '/educations'; // + /{id}
  
  // Education Video endpoints
  static const String educationVideos = '/education/get-educational-videos';
  static const String educationVideosByCategory = '/education/get-educational-videos'; // + /{id}
  
  // Private constructor untuk mencegah instantiasi
  ApiEndpoints._();
}

