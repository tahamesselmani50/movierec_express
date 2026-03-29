import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/models/user_model.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(const FlutterSecureStorage());
});

// Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> initialize() async {
    await _authService.init();
    final user = await _authService.getCurrentUser();
    state = state.copyWith(user: user, isInitialized: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.login(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.register(
          username: username, email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = state.copyWith(clearUser: true, clearError: true);
  }

  Future<void> updateFavoriteGenres(List<int> genreIds) async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(favoriteGenreIds: genreIds);
    final saved = await _authService.updateUser(updated);
    state = state.copyWith(user: saved);
  }

  Future<void> rateMovie(int movieId, double rating) async {
    if (state.user == null) return;
    final ratings = Map<String, double>.from(state.user!.movieRatings);
    ratings[movieId.toString()] = rating;
    final watched = List<int>.from(state.user!.watchedMovieIds);
    if (!watched.contains(movieId)) watched.add(movieId);
    final updated = state.user!.copyWith(movieRatings: ratings, watchedMovieIds: watched);
    final saved = await _authService.updateUser(updated);
    state = state.copyWith(user: saved);
  }

  Future<void> toggleFavorite(int movieId) async {
    if (state.user == null) return;
    final watched = List<int>.from(state.user!.watchedMovieIds);
    if (watched.contains(movieId)) {
      watched.remove(movieId);
    } else {
      watched.add(movieId);
    }
    final updated = state.user!.copyWith(watchedMovieIds: watched);
    final saved = await _authService.updateUser(updated);
    state = state.copyWith(user: saved);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// Providers
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).user;
});
