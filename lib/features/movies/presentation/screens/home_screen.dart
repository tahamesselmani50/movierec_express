import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_card.dart';
import '../../data/models/movie_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final trending = ref.watch(trendingMoviesProvider);
    final popular = ref.watch(popularMoviesProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppTheme.background,
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.movie_filter_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('MovieRec',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: AppTheme.surfaceVariant,
                  radius: 18,
                  child: Text(
                    user?.username.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16),
                  ),
                ),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.headlineSmall,
                      children: [
                        const TextSpan(text: 'Bonsoir, '),
                        TextSpan(
                          text: user?.username ?? 'Cinéphile',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800),
                        ),
                        const TextSpan(text: ' 👋'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Qu'est-ce qu'on regarde ce soir ?",
                      style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 28),

                  // Trending Section
                  _SectionHeader(title: 'Tendances', subtitle: 'Cette semaine'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 165,
                    child: trending.when(
                      loading: () => _HorizontalShimmer(count: 3, width: 280, height: 165),
                      error: (e, _) => _ErrorWidget(message: e.toString()),
                      data: (movies) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.take(8).length,
                        itemBuilder: (_, i) => MovieCardLarge(movie: movies[i]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Now Playing
                  _SectionHeader(title: 'En salle', subtitle: 'Actuellement'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 240,
                    child: nowPlaying.when(
                      loading: () => _HorizontalShimmer(count: 4, width: 130, height: 195),
                      error: (e, _) => _ErrorWidget(message: e.toString()),
                      data: (movies) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.take(10).length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: MovieCard(movie: movies[i]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Popular
                  _SectionHeader(title: 'Populaires', subtitle: 'Tout le monde en parle'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 240,
                    child: popular.when(
                      loading: () => _HorizontalShimmer(count: 4, width: 130, height: 195),
                      error: (e, _) => _ErrorWidget(message: e.toString()),
                      data: (movies) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.take(10).length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: MovieCard(movie: movies[i]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            Text(subtitle,
                style: const TextStyle(
                    color: AppTheme.textHint, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _HorizontalShimmer extends StatelessWidget {
  final int count;
  final double width;
  final double height;

  const _HorizontalShimmer(
      {required this.count, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: count,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Shimmer.fromColors(
          baseColor: AppTheme.surfaceVariant,
          highlightColor: AppTheme.divider,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.textHint, size: 32),
          const SizedBox(height: 8),
          const Text('Vérifie ta connexion',
              style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text('(Vérifie aussi ta clé TMDB)',
              style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
        ],
      ),
    );
  }
}
