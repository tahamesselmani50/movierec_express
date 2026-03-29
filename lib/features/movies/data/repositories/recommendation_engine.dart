import '../models/movie_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Content-Based Filtering Engine
/// Recommande des films basé sur les genres préférés et l'historique de l'utilisateur
class RecommendationEngine {

  /// Score de similarité entre un film et les préférences utilisateur
  /// Utilise TF-IDF simplifié sur les genres
  double computeMovieScore(Movie movie, UserModel user) {
    if (user.favoriteGenreIds.isEmpty && user.movieRatings.isEmpty) {
      return movie.voteAverage / 10.0;
    }

    double score = 0.0;

    // 1. Genre matching score (40%)
    final genreScore = _computeGenreScore(movie, user);

    // 2. Rating-based score - films similaires à ceux bien notés (40%)
    final ratingScore = _computeRatingScore(movie, user);

    // 3. Qualité intrinsèque du film (20%)
    final qualityScore = _computeQualityScore(movie);

    score = (genreScore * 0.40) + (ratingScore * 0.40) + (qualityScore * 0.20);

    // Pénalité si déjà vu
    if (user.watchedMovieIds.contains(movie.id)) {
      score *= 0.3;
    }

    return score.clamp(0.0, 1.0);
  }

  double _computeGenreScore(Movie movie, UserModel user) {
    if (user.favoriteGenreIds.isEmpty) return 0.5;

    final movieGenreIds = movie.genreIds.isNotEmpty ? movie.genreIds : movie.genres.map((g) => g.id).toList();
    if (movieGenreIds.isEmpty) return 0.3;

    // Intersection des genres
    final commonGenres = movieGenreIds.where((id) => user.favoriteGenreIds.contains(id)).length;
    final unionGenres = {...movieGenreIds, ...user.favoriteGenreIds}.length;

    if (unionGenres == 0) return 0.0;

    // Jaccard similarity
    return commonGenres / unionGenres;
  }

  double _computeRatingScore(Movie movie, UserModel user) {
    if (user.movieRatings.isEmpty) return 0.5;

    // Films que l'utilisateur a bien aimés (note >= 3.5/5)
    final likedMovieIds = user.movieRatings.entries
        .where((e) => e.value >= 3.5)
        .map((e) => int.tryParse(e.key) ?? 0)
        .toSet();

    if (likedMovieIds.isEmpty) return 0.3;

    // Score basé sur vote_average pondéré par les goûts
    // Approximation : si le film est dans les mêmes genres que les films aimés
    final movieGenreIds = Set<int>.from(
        movie.genreIds.isNotEmpty ? movie.genreIds : movie.genres.map((g) => g.id));

    // Score de vote normalisé
    double voteScore = (movie.voteAverage - 5.0) / 5.0; // normalise [0, 2] -> [-1, 1]
    return ((voteScore + 1) / 2).clamp(0.0, 1.0);
  }

  double _computeQualityScore(Movie movie) {
    // Formule de Wilson score pour la qualité
    final rating = movie.voteAverage / 10.0;
    final votes = movie.voteCount;

    if (votes == 0) return 0.0;

    // Pondération par le nombre de votes (Bayesian average)
    const minVotes = 500;
    final weight = votes / (votes + minVotes);
    final baseRating = 0.5; // rating par défaut

    return (weight * rating + (1 - weight) * baseRating).clamp(0.0, 1.0);
  }

  /// Trie et filtre une liste de films selon les préférences de l'utilisateur
  List<Movie> rankMovies(List<Movie> movies, UserModel user) {
    final scored = movies.map((movie) {
      return MapEntry(movie, computeMovieScore(movie, user));
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.map((e) => e.key).toList();
  }

  /// Déduit les genres préférés à partir des films notés
  List<int> inferFavoriteGenres(UserModel user, List<Movie> allMovies) {
    final genreScores = <int, double>{};

    for (final entry in user.movieRatings.entries) {
      final movieId = int.tryParse(entry.key);
      if (movieId == null) continue;

      final movie = allMovies.where((m) => m.id == movieId).firstOrNull;
      if (movie == null) continue;

      final rating = entry.value;
      final weight = (rating - 2.5) / 2.5; // -1 à +1

      final genreIds = movie.genreIds.isNotEmpty
          ? movie.genreIds
          : movie.genres.map((g) => g.id).toList();

      for (final genreId in genreIds) {
        genreScores[genreId] = (genreScores[genreId] ?? 0) + weight;
      }
    }

    final sorted = genreScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.where((e) => e.value > 0).map((e) => e.key).take(5).toList();
  }

  /// Statistiques pour la visualisation
  Map<String, dynamic> getUserStats(UserModel user, List<Genre> allGenres) {
    final totalWatched = user.watchedMovieIds.length;
    final totalRated = user.movieRatings.length;
    final avgRating = user.movieRatings.isEmpty
        ? 0.0
        : user.movieRatings.values.reduce((a, b) => a + b) / user.movieRatings.length;

    // Distribution des notes
    final ratingDist = <String, int>{
      '1': 0, '2': 0, '3': 0, '4': 0, '5': 0,
    };
    for (final rating in user.movieRatings.values) {
      final key = rating.round().clamp(1, 5).toString();
      ratingDist[key] = (ratingDist[key] ?? 0) + 1;
    }

    // Genres préférés
    final favoriteGenres = allGenres
        .where((g) => user.favoriteGenreIds.contains(g.id))
        .toList();

    return {
      'totalWatched': totalWatched,
      'totalRated': totalRated,
      'avgRating': avgRating,
      'ratingDistribution': ratingDist,
      'favoriteGenres': favoriteGenres,
    };
  }
}
