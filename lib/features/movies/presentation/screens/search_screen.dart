import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/movies_provider.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Recherche'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Titre, acteur, genre...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textHint),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppTheme.textHint),
                        onPressed: () {
                          _ctrl.clear();
                          ref.read(searchProvider.notifier).clear();
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                setState(() {});
                if (query.length >= 2) {
                  ref.read(searchProvider.notifier).search(query);
                } else if (query.isEmpty) {
                  ref.read(searchProvider.notifier).clear();
                }
              },
            ),
          ),
          Expanded(
            child: _buildResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.query.isEmpty) {
      return _EmptySearchHint();
    }

    if (state.results.isEmpty && state.query.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, color: AppTheme.textHint, size: 56),
            const SizedBox(height: 16),
            Text('Aucun résultat pour "${state.query}"',
                style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: state.results.length,
      itemBuilder: (_, i) => MovieCard(
        movie: state.results[i],
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class _EmptySearchHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hints = [
      ('🎬', 'Action'),
      ('😂', 'Comédie'),
      ('👻', 'Horreur'),
      ('🚀', 'Sci-Fi'),
      ('💕', 'Romance'),
      ('🔍', 'Mystère'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recherches populaires',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hints
                .map((h) => GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.divider, width: 0.5),
                        ),
                        child: Text('${h.$1} ${h.$2}',
                            style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 13)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}


