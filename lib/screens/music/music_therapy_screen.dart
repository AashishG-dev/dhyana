// lib/screens/music/music_therapy_screen.dart
import 'package:dhyana/models/music_track_model.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/widgets/cards/music_track_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

class MusicTherapyScreen extends ConsumerStatefulWidget {
  const MusicTherapyScreen({super.key});

  @override
  ConsumerState<MusicTherapyScreen> createState() => _MusicTherapyScreenState();
}

class _MusicTherapyScreenState extends ConsumerState<MusicTherapyScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = ref.watch(musicSearchQueryProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Music Therapy',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Downloads',
            onPressed: () => context.push('/offline-content'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF2C2C2C)]
                : [AppColors.backgroundLight, const Color(0xFFF0F0F0)],
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: searchQuery.isEmpty
                  ? _buildCategoryView()
                  : _buildSearchResultsView(searchQuery),
            ),
            const MiniMusicPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for music...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              ref.read(musicSearchQueryProvider.notifier).state = '';
              FocusScope.of(context).unfocus();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {}); // To show/hide the clear button
        },
        onSubmitted: (value) {
          ref.read(musicSearchQueryProvider.notifier).state = value.trim();
        },
      ),
    );
  }

  Widget _buildCategoryView() {
    final audioService = ref.watch(musicAudioServiceProvider);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final musicTracksAsync = ref.watch(jamendoMusicProvider(
            (query: category['query']!, limit: 10)
        ));

        musicTracksAsync.whenData((tracks) {
          if (tracks.isNotEmpty) {
            audioService.preloadMusic(tracks.first);
          }
        });

        return musicTracksAsync.when(
          data: (tracks) => _buildCategoryRow(context, ref, category, tracks),
          loading: () => const SizedBox(height: 220, child: LoadingWidget()),
          error: (e, st) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Could not load ${category['title']}.'),
          ),
        );
      },
    );
  }

  Widget _buildSearchResultsView(String query) {
    final searchResultsAsync = ref.watch(musicSearchResultsProvider(query));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Results for "$query"',
                  style: AppTextStyles.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear_all_rounded, size: 20),
                label: const Text('Clear'),
                onPressed: () {
                  _searchController.clear();
                  ref.read(musicSearchQueryProvider.notifier).state = '';
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: searchResultsAsync.when(
            data: (tracks) {
              if (tracks.isEmpty) {
                return Center(child: Text('No results found for "$query"'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return MusicTrackCard(
                    track: track,
                    onTap: () => context.push('/music-player', extra: {
                      'track': track,
                      'playlist': tracks,
                    }),
                  );
                },
              );
            },
            loading: () => const LoadingWidget(message: 'Searching...'),
            error: (e, st) => Center(child: Text('Error searching for music: $e')),
          ),
        ),
      ],
    );
  }

  static const List<Map<String, String>> _categories = [
    {'title': 'Ambient', 'query': 'ambient'},
    {'title': 'Nature Sounds', 'query': 'nature sounds'},
    {'title': 'Calm Piano', 'query': 'calm piano'},
    {'title': 'Relaxing', 'query': 'relaxing music'},
  ];

  Widget _buildCategoryRow(BuildContext context, WidgetRef ref, Map<String, String> category, List<MusicTrackModel> tracks) {
    const int previewCount = 9;
    final bool hasMore = tracks.length > previewCount;
    final int itemCount = hasMore ? previewCount + 1 : tracks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
          child: Text(category['title']!, style: AppTextStyles.headlineSmall),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (hasMore && index == previewCount) {
                return _buildMoreCard(context, category);
              }

              final track = tracks[index];
              return MusicTrackCard(
                track: track,
                onTap: () => context.push('/music-player', extra: {
                  'track': track,
                  'playlist': tracks,
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoreCard(BuildContext context, Map<String, String> category) {
    return GestureDetector(
      onTap: () {
        context.push('/music-category', extra: category);
      },
      child: SizedBox(
        width: 180,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_forward_ios_rounded),
                const SizedBox(height: 8),
                Text('More', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}