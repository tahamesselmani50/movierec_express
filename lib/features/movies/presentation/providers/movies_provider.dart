import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/tmdb_api_service.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/recommendation_engine.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Core providers
final tmdbServiceProvider = Provider<TmdbApiService>((ref) => TmdbApiService());
final recommendationEngineProvider = Provider<RecommendationEngine>((ref) => RecommendationEngine());

// Genres
final genresProvider = FutureProvider<List<Genre>>((ref) async {
  return ref.read(tmdbServiceProvider).getGenres();
});

// Trending movies
final trendingMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  return ref.read(tmdbServiceProvider).getTrending();
});

// Popular movies
final popularMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  return ref.read(tmdbServiceProvider).getPopular();
});

// Top rated
final topRatedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  return ref.read(tmdbServiceProvider).getTopRated();
});

// Now playing
final nowPlayingProvider = FutureProvider<List<Movie>>((ref) async {
  return ref.read(tmdbServiceProvider).getNowPlaying();
});

// Recommended movies (content-based filtering)
final recommendedMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final engine = ref.read(recommendationEngineProvider);
  final tmdb = ref.read(tmdbServiceProvider);

  if (user == null || user.favoriteGenreIds.isEmpty) {
    return tmdb.getTopRated();
  }

  // Fetch films pour chaque genre préféré
  final allMovies = <Movie>[];
  for (final genreId in user.favoriteGenreIds.take(3)) {
    final movies = await tmdb.getMoviesByGenre(genreId);
    allMovies.addAll(movies);
  }

  // Dédoublonner
  final seen = <int>{};
  final unique = allMovies.where((m) => seen.add(m.id)).toList();

  // Ranker avec l'engine content-based
  return engine.rankMovies(unique, user);
});

// Search state
class SearchState {
  final String query;
  final List<Movie> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Movie>? results,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final TmdbApiService _tmdb;

  SearchNotifier(this._tmdb) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true, clearError: true);

    try {
      final results = await _tmdb.searchMovies(query);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() => state = const SearchState();
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(tmdbServiceProvider));
});

// Movie detail
final movieDetailProvider = FutureProvider.family<Movie, int>((ref, movieId) async {
  return ref.read(tmdbServiceProvider).getMovieDetails(movieId);
});

// Similar movies
final similarMoviesProvider = FutureProvider.family<List<Movie>, int>((ref, movieId) async {
  return ref.read(tmdbServiceProvider).getSimilarMovies(movieId);
});

// Movie credits
final movieCreditsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, movieId) async {
  return ref.read(tmdbServiceProvider).getMovieCredits(movieId);
});
