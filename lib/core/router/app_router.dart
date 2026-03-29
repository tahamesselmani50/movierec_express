import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/genre_picker_screen.dart';
import '../../features/movies/presentation/screens/home_screen.dart';
import '../../features/movies/presentation/screens/movie_detail_screen.dart';
import '../../features/movies/presentation/screens/search_screen.dart';
import '../../features/movies/presentation/screens/recommendations_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isInitialized = authState.isInitialized;
      final isAuth = authState.isAuthenticated;
      final location = state.uri.toString();

      if (!isInitialized) return '/splash';

      if (!isAuth && location != '/login' && location != '/register') {
        return '/login';
      }

      if (isAuth && (location == '/login' || location == '/register' || location == '/splash')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/genre-picker', builder: (_, __) => const GenrePickerScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: '/recommendations', builder: (_, __) => const RecommendationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MovieDetailScreen(movieId: id);
        },
      ),
    ],
  );
});
