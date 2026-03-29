import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/movies/data/repositories/recommendation_engine.dart';
import '../../../../features/movies/presentation/providers/movies_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final genresAsync = ref.watch(genresProvider);
    final engine = RecommendationEngine();

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = genresAsync.maybeWhen(
      data: (genres) => engine.getUserStats(user, genres),
      orElse: () => <String, dynamic>{},
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.background,
            automaticallyImplyLeading: false,
            floating: true,
            title: const Text('Mon Profil',
                style: TextStyle(fontWeight: FontWeight.w900)),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded, size: 16, color: AppTheme.textHint),
                label: const Text('Déconnexion',
                    style: TextStyle(color: AppTheme.textHint, fontSize: 13)),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + info
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            Text(user.email,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Membre depuis ${_formatDate(user.createdAt)}',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Stats cards
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.movie_outlined,
                        value: '${stats['totalWatched'] ?? 0}',
                        label: 'Sauvegardés',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.star_rounded,
                        value: '${stats['totalRated'] ?? 0}',
                        label: 'Notés',
                        color: AppTheme.accent,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.bar_chart_rounded,
                        value: stats['avgRating'] != null
                            ? (stats['avgRating'] as double).toStringAsFixed(1)
                            : '0.0',
                        label: 'Moy. notes',
                        color: AppTheme.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Rating distribution chart
                  if ((stats['totalRated'] ?? 0) > 0) ...[
                    const Text('Distribution de vos notes',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Visualisation de vos préférences',
                        style: TextStyle(
                            color: AppTheme.textHint, fontSize: 12)),
                    const SizedBox(height: 16),
                    Container(
                      height: 180,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _RatingBarChart(
                          ratingDist: stats['ratingDistribution']
                              as Map<String, int>? ??
                              {}),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Genre preferences
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Genres préférés',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      TextButton(
                        onPressed: () => context.go('/genre-picker'),
                        child: const Text('Modifier',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  genresAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (genres) {
                      final favGenres = genres
                          .where((g) => user.favoriteGenreIds.contains(g.id))
                          .toList();
                      if (favGenres.isEmpty) {
                        return GestureDetector(
                          onTap: () => context.go('/genre-picker'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppTheme.divider, width: 0.5),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_rounded,
                                    color: AppTheme.primary),
                                SizedBox(width: 10),
                                Text('Ajouter des genres préférés',
                                    style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: favGenres
                            .map((g) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppTheme.divider, width: 0.5),
                                  ),
                                  child: Text('${g.emoji} ${g.name}',
                                      style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      return '${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '2025';
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textHint, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _RatingBarChart extends StatelessWidget {
  final Map<String, int> ratingDist;

  const _RatingBarChart({required this.ratingDist});

  @override
  Widget build(BuildContext context) {
    final maxY = ratingDist.values.isEmpty
        ? 1
        : ratingDist.values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxY + 1).toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} film(s)',
                const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const stars = ['1★', '2★', '3★', '4★', '5★'];
                final idx = value.toInt();
                if (idx < 0 || idx >= stars.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(stars[idx],
                      style: const TextStyle(
                          color: AppTheme.textHint, fontSize: 11)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(
                    color: AppTheme.textHint, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppTheme.divider, strokeWidth: 0.5),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(5, (i) {
          final key = (i + 1).toString();
          final count = ratingDist[key] ?? 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: _barColor(i),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Color _barColor(int index) {
    const colors = [
      Color(0xFFCF6679),
      Color(0xFFFF9800),
      Color(0xFFFFD700),
      Color(0xFF8BC34A),
      Color(0xFF4CAF50),
    ];
    return colors[index];
  }
}
