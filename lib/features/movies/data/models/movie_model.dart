class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final List<Genre> genres;
  final double? popularity;
  final String? originalLanguage;

  const Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.voteCount = 0,
    this.releaseDate,
    this.genreIds = const [],
    this.genres = const [],
    this.popularity,
    this.originalLanguage,
  });

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get backdropUrl =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w780$backdropPath' : '';

  String get year => releaseDate?.isNotEmpty == true
      ? releaseDate!.substring(0, 4)
      : 'N/A';

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>() ?? [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => Genre.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      popularity: (json['popularity'] as num?)?.toDouble(),
      originalLanguage: json['original_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'vote_count': voteCount,
        'release_date': releaseDate,
        'genre_ids': genreIds,
        'popularity': popularity,
        'original_language': originalLanguage,
      };
}

class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] as int, name: json['name'] as String);
  }

  // Emoji pour chaque genre
  String get emoji {
    const map = {
      28: '💥', // Action
      12: '🗺️', // Adventure
      16: '🎨', // Animation
      35: '😂', // Comedy
      80: '🔫', // Crime
      99: '📹', // Documentary
      18: '😢', // Drama
      10751: '👨‍👩‍👧', // Family
      14: '🧙', // Fantasy
      36: '⚔️', // History
      27: '👻', // Horror
      10402: '🎵', // Music
      9648: '🔍', // Mystery
      10749: '💕', // Romance
      878: '🚀', // Sci-Fi
      10770: '📺', // TV Movie
      53: '😰', // Thriller
      10752: '🎖️', // War
      37: '🤠', // Western
    };
    return map[id] ?? '🎬';
  }
}
