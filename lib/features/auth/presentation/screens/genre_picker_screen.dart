import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/movies/presentation/providers/movies_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/movies/data/models/movie_model.dart';

class GenrePickerScreen extends ConsumerStatefulWidget {
  const GenrePickerScreen({super.key});

  @override
  ConsumerState<GenrePickerScreen> createState() => _GenrePickerScreenState();
}

class _GenrePickerScreenState extends ConsumerState<GenrePickerScreen> {
  final Set<int> _selected = {};

  Future<void> _confirm() async {
    await ref
        .read(authNotifierProvider.notifier)
        .updateFavoriteGenres(_selected.toList());
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final genresAsync = ref.watch(genresProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text('Tes genres\npréférés ?',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      )),
              const SizedBox(height: 12),
              Text(
                'Sélectionne au moins 2 genres pour personnaliser tes recommandations.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 36),
              Expanded(
                child: genresAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                      child: Text('Erreur: $e',
                          style: const TextStyle(color: AppTheme.error))),
                  data: (genres) => GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: genres.length,
                    itemBuilder: (context, i) => _GenreTile(
                      genre: genres[i],
                      selected: _selected.contains(genres[i].id),
                      onTap: () => setState(() {
                        if (_selected.contains(genres[i].id)) {
                          _selected.remove(genres[i].id);
                        } else {
                          _selected.add(genres[i].id);
                        }
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_selected.isNotEmpty)
                Text(
                  '${_selected.length} genre(s) sélectionné(s)',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selected.length >= 2 ? _confirm : null,
                  child: const Text('Continuer'),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Passer cette étape',
                    style: TextStyle(color: AppTheme.textHint)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreTile extends StatelessWidget {
  final Genre genre;
  final bool selected;
  final VoidCallback onTap;

  const _GenreTile(
      {required this.genre, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.divider,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(genre.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                genre.name,
                style: TextStyle(
                  color: selected ? AppTheme.primary : AppTheme.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.primary, size: 16),
          ],
        ),
      ),
    );
  }
}
