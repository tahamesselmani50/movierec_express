import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_card.dart';

class MovieDetailScreen extends ConsumerWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(movieDetailProvider(movieId));
    final similarAsync = ref.watch(similarMoviesProvider(movieId));
    final creditsAsync = ref.watch(movieCreditsProvider(movieId));
    final user = ref.watch(currentUserProvider);

    final userRating = user?.movieRatings[movieId.toString()] ?? 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: movieAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text(e.toString(),
                style: const TextStyle(color: AppTheme.error))),
        data: (movie) {
          final isWatched = user?.watchedMovieIds.contains(movie.id) ?? false;

          return CustomScrollView(
            slivers: [
              // Hero backdrop + appbar
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.background,
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      movie.backdropPath != null
                          ? CachedNetworkImage(
                              imageUrl: movie.backdropUrl,
                              fit: BoxFit.cover,
                            )
                          : Container(color: AppTheme.surfaceVariant),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.background,
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + metadata
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster miniature
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: movie.posterUrl,
                              width: 90,
                              height: 130,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                  width: 90,
                                  height: 130,
                                  color: AppTheme.surfaceVariant),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(movie.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w800)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: AppTheme.accent, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      movie.voteAverage.toStringAsFixed(1),
                                      style: const TextStyle(
                                          color: AppTheme.accent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15),
                                    ),
                                    Text(
                                      ' (${movie.voteCount})',
                                      style: const TextStyle(
                                          color: AppTheme.textHint,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(movie.year,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: movie.genres
                                      .take(3)
                                      .map((g) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: AppTheme.primary
                                                      .withOpacity(0.4)),
                                            ),
                                            child: Text(g.name,
                                                style: const TextStyle(
                                                    color: AppTheme.primary,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => ref
                                  .read(authNotifierProvider.notifier)
                                  .toggleFavorite(movie.id),
                              icon: Icon(
                                  isWatched
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 18),
                              label: Text(isWatched ? 'Sauvegardé' : 'Sauvegarder'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isWatched
                                    ? AppTheme.primary
                                    : AppTheme.surfaceVariant,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Your Rating
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Votre note',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Center(
                              child: RatingBar.builder(
                                initialRating: userRating,
                                minRating: 0.5,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 36,
                                itemBuilder: (context, _) => const Icon(
                                    Icons.star_rounded,
                                    color: AppTheme.accent),
                                onRatingUpdate: (rating) {
                                  ref
                                      .read(authNotifierProvider.notifier)
                                      .rateMovie(movie.id, rating);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Note enregistrée : $rating ⭐'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (userRating > 0) ...[
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Tu as noté ce film $userRating/5 ⭐',
                                  style: const TextStyle(
                                      color: AppTheme.accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Overview
                      if (movie.overview?.isNotEmpty == true) ...[
                        const Text('Synopsis',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        const SizedBox(height: 10),
                        Text(movie.overview!,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.6,
                                fontSize: 14)),
                        const SizedBox(height: 24),
                      ],

                      // Cast
                      creditsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (credits) {
                          final cast = (credits['cast'] as List<dynamic>?)
                                  ?.take(10)
                                  .toList() ??
                              [];
                          if (cast.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Casting',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: cast.length,
                                  itemBuilder: (_, i) {
                                    final actor = cast[i] as Map<String, dynamic>;
                                    final profilePath =
                                        actor['profile_path'] as String?;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 14),
                                      child: Column(
                                        children: [
                                          CircleAvatar(
                                            radius: 32,
                                            backgroundColor: AppTheme.surfaceVariant,
                                            backgroundImage: profilePath != null
                                                ? CachedNetworkImageProvider(
                                                    'https://image.tmdb.org/t/p/w185$profilePath')
                                                : null,
                                            child: profilePath == null
                                                ? const Icon(Icons.person_rounded,
                                                    color: AppTheme.textHint)
                                                : null,
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: 64,
                                            child: Text(
                                              actor['name'] as String? ?? '',
                                              style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 10),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),

                      // Similar movies
                      const Text('Films similaires',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      const SizedBox(height: 14),
                      similarAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (movies) => SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movies.take(8).length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: MovieCard(movie: movies[i]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
