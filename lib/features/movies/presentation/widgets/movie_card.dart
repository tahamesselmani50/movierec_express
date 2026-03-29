import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 130,
    this.height = 195,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  movie.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl: movie.posterUrl,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _shimmer(width, height),
                          errorWidget: (_, __, ___) => _placeholder(width, height),
                        )
                      : _placeholder(width, height),
                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppTheme.accent, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
            Text(
              movie.year,
              style: const TextStyle(color: AppTheme.textHint, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer(double w, double h) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceVariant,
      highlightColor: AppTheme.divider,
      child: Container(
          width: w, height: h, decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14))),
    );
  }

  Widget _placeholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: AppTheme.surfaceVariant,
      child: const Icon(Icons.movie_outlined, color: AppTheme.textHint, size: 40),
    );
  }
}

// Large horizontal movie card for featured section
class MovieCardLarge extends StatelessWidget {
  final Movie movie;

  const MovieCardLarge({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              movie.backdropPath != null
                  ? CachedNetworkImage(
                      imageUrl: movie.backdropUrl,
                      width: 280,
                      height: 165,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppTheme.surfaceVariant,
                        highlightColor: AppTheme.divider,
                        child: Container(width: 280, height: 165, color: AppTheme.surfaceVariant),
                      ),
                    )
                  : Container(
                      width: 280,
                      height: 165,
                      color: AppTheme.surfaceVariant,
                      child: const Icon(Icons.movie_outlined, color: AppTheme.textHint, size: 48),
                    ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              // Info at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppTheme.accent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            movie.year,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Rating badge top right
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('TRENDING',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
