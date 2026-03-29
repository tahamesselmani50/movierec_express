import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String passwordHash;

  @HiveField(4)
  final String createdAt;

  @HiveField(5)
  List<int> favoriteGenreIds;

  @HiveField(6)
  List<int> watchedMovieIds;

  @HiveField(7)
  Map<String, double> movieRatings; // movieId -> rating

  @HiveField(8)
  String? avatarUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.favoriteGenreIds = const [],
    this.watchedMovieIds = const [],
    this.movieRatings = const {},
    this.avatarUrl,
  });

  UserModel copyWith({
    String? username,
    String? email,
    List<int>? favoriteGenreIds,
    List<int>? watchedMovieIds,
    Map<String, double>? movieRatings,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash,
      createdAt: createdAt,
      favoriteGenreIds: favoriteGenreIds ?? this.favoriteGenreIds,
      watchedMovieIds: watchedMovieIds ?? this.watchedMovieIds,
      movieRatings: movieRatings ?? this.movieRatings,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
