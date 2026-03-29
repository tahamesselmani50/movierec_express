class AppConstants {
  // ⚠️ REMPLACE PAR TA CLÉ TMDB (themoviedb.org → Settings → API)
  static const String tmdbApiKey = 'ceb6a4477b483f5d69cf6edb5dfd5ace';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String tmdbPosterW500 = '$tmdbImageBaseUrl/w500';
  static const String tmdbPosterOriginal = '$tmdbImageBaseUrl/original';
  static const String tmdbBackdropW780 = '$tmdbImageBaseUrl/w780';

  // Hive box names
  static const String userBox = 'users';
  static const String favoritesBox = 'favorites';
  static const String watchedBox = 'watched';
  static const String cacheBox = 'cache';

  // Secure storage keys
  static const String currentUserKey = 'current_user';
  static const String jwtTokenKey = 'jwt_token';

  // Recommendation
  static const int maxRecommendations = 20;
  static const int minRatingToCount = 3; // note min pour considérer un film "aimé"
}
