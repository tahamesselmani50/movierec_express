import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_card.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final recommended = ref.watch(recommendedMoviesProvider);
    final genres = ref.watch(genresProvider);

    final favoriteGenreNames = genres.maybeWhen(
      data: (g) => g
          .where((genre) =>
              user?.favoriteGenreIds.contains(genre.id) ?? false)
          .map((g) => '${g.emoji} ${g.name}')
          .toList(),
      orElse: () => <String>[],
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.background,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pour vous',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 22)),
                const Text('Basé sur vos goûts',
                    style: TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 12,
                        fontWeight: FontWeight.w400)),
              ],
            ),
            actions: [
              if (user?.favoriteGenreIds.isEmpty ?? true)
                TextButton.icon(
                  onPressed: () => context.go('/genre-picker'),
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Configurer'),
                ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Algorithm info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.15),
                          AppTheme.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.primary.withOpacity(0.3), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Content-Based Filtering',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(
                                'Similarité Jaccard sur les genres • Wilson Score • ${user?.movieRatings.length ?? 0} films notés',
                                style: const TextStyle(
                                    color: AppTheme.textHint,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Favorite genres chips
                  if (favoriteGenreNames.isNotEmpty) ...[
                    const Text('Vos genres préférés',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: favoriteGenreNames
                          .map((name) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          AppTheme.primary.withOpacity(0.3)),
                                ),
                                child: Text(name,
                                    style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Empty state - no genres
                  if (user?.favoriteGenreIds.isEmpty ?? true) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.tune_rounded,
                              color: AppTheme.textHint, size: 48),
                          const SizedBox(height: 14),
                          const Text('Personnalise tes recommandations',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          const Text(
                            'Sélectionne tes genres préférés et note des films pour que l\'algorithme apprenne tes goûts.',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: () => context.go('/genre-picker'),
                            child: const Text('Choisir mes genres'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Results title
                  const Text('Films recommandés',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Movie grid
          recommended.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.error, size: 40),
                      const SizedBox(height: 12),
                      Text(e.toString(),
                          style: const TextStyle(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            data: (movies) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => MovieCard(movie: movies[i]),
                  childCount: movies.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
