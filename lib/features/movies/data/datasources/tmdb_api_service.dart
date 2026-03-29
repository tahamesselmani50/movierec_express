import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/movie_model.dart';

class TmdbApiService {
  late final Dio _dio;

  TmdbApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      queryParameters: {
        'api_key': AppConstants.tmdbApiKey,
        'language': 'fr-FR',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => print('[TMDB] $obj'),
    ));
  }

  Future<List<Movie>> getTrending({int page = 1}) async {
    final res = await _dio.get('/trending/movie/week', queryParameters: {'page': page});
    return _parseMovies(res.data);
  }

  Future<List<Movie>> getPopular({int page = 1}) async {
    final res = await _dio.get('/movie/popular', queryParameters: {'page': page});
    return _parseMovies(res.data);
  }

  Future<List<Movie>> getTopRated({int page = 1}) async {
    final res = await _dio.get('/movie/top_rated', queryParameters: {'page': page});
    return _parseMovies(res.data);
  }

  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final res = await _dio.get('/movie/now_playing', queryParameters: {'page': page});
    return _parseMovies(res.data);
  }

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    final res = await _dio.get('/search/movie', queryParameters: {'query': query, 'page': page});
    return _parseMovies(res.data);
  }

  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final res = await _dio.get('/discover/movie', queryParameters: {
      'with_genres': genreId,
      'page': page,
      'sort_by': 'vote_average.desc',
      'vote_count.gte': 100,
    });
    return _parseMovies(res.data);
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final res = await _dio.get('/movie/$movieId');
    return Movie.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final res = await _dio.get('/movie/$movieId/similar');
    return _parseMovies(res.data);
  }

  Future<List<Movie>> getRecommendedMovies(int movieId) async {
    final res = await _dio.get('/movie/$movieId/recommendations');
    return _parseMovies(res.data);
  }

  Future<List<Genre>> getGenres() async {
    final res = await _dio.get('/genre/movie/list');
    final genres = res.data['genres'] as List<dynamic>;
    return genres.map((g) => Genre.fromJson(g as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getMovieCredits(int movieId) async {
    final res = await _dio.get('/movie/$movieId/credits');
    return res.data as Map<String, dynamic>;
  }

  List<Movie> _parseMovies(dynamic data) {
    final results = data['results'] as List<dynamic>? ?? [];
    return results
        .map((m) => Movie.fromJson(m as Map<String, dynamic>))
        .where((m) => m.posterPath != null)
        .toList();
  }
}
