// lib/screens/home/home_screen.dart
import 'package:dhyana/core/utils/gamification_utils.dart';
import 'package:dhyana/models/progress_data_model.dart';
import 'package:dhyana/models/quote_model.dart';
import 'package:dhyana/models/recommendation_model.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/providers/progress_provider.dart';
import 'package:dhyana/providers/recommendation_provider.dart';
import 'package:dhyana/widgets/common/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/providers/music_provider.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _catController;

  @override
  void initState() {
    super.initState();
    _waveController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _catController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));
    _waveController.repeat();
    _catController.repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _catController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Exit App',
      message: 'Are you sure you want to leave?',
      confirmText: 'Exit',
      cancelText: 'Stay',
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final musicPlayerState = ref.watch(musicPlayerProvider);
    final shouldShowMiniPlayer = musicPlayerState.currentTrack != null &&
        (musicPlayerState.playerState == PlayerState.playing ||
            musicPlayerState.playerState == PlayerState.paused);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: userProfileAsync.when(
          data: (userModel) {
            return _buildContent(context, ref, userModel);
          },
          loading: () => const LoadingWidget(message: 'Loading your space...'),
          error: (e, st) =>
              Center(child: Text('Error loading profile: $e')),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowMiniPlayer) const MiniMusicPlayer(),
            const CustomBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, UserModel? userModel) {
    final quoteAsync = ref.watch(quoteOfTheDayProvider);
    final recommendationsAsync = ref.watch(recommendationProvider);

    return Column(
      children: [
        _buildHeader(context, userModel),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildQuoteCard(context, quoteAsync),
              const SizedBox(height: 24),
              if (userModel != null) ...[
                _buildUserSpecificContent(context, ref, userModel),
                const SizedBox(height: 24),
              ],
              recommendationsAsync.when(
                data: (recommendations) => recommendations.isNotEmpty
                    ? _buildRecommendations(context, recommendations)
                    : const SizedBox.shrink(),
                loading: () => const LoadingWidget(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              _buildFeatureGrid(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? user) {
    final theme = Theme.of(context);
    final isGuest = user == null;
    final userName = user?.name ?? 'Guest';

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/Circles.json',
              fit: BoxFit.cover,
              controller: _waveController,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu),
                    onSelected: (value) {
                      if (value == 'offline') {
                        context.push('/offline-content');
                      } else if (value == 'feedback') {
                        context.push('/feedback');
                      } else if (value == 'notifications') {
                        context.push('/notification-settings');
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'notifications',
                        child: ListTile(
                          leading: Icon(Icons.notifications_outlined),
                          title: Text('Notification Settings'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'offline',
                        child: ListTile(
                          leading: Icon(Icons.download_for_offline_outlined),
                          title: Text('Offline Content'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'feedback',
                        child: ListTile(
                          leading: Icon(Icons.feedback_outlined),
                          title: Text('Send Feedback'),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Dhyana',
                    style: AppTextStyles.titleLarge
                        .copyWith(color: Colors.indigoAccent),
                  ),
                  const ProfileAvatar(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 110,
                  width: 110,
                  child: Lottie.asset(
                    'assets/animations/cat_header.json',
                    controller: _catController,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isGuest)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Hello, Guest!',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: Colors.blueGrey,
                                  fontSize: 24.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.person,
                                  size: 24, color: Colors.white),
                            ],
                          ),
                        )
                      else
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            children: [
                              const TextSpan(text: 'Hello, '),
                              TextSpan(
                                text: '${userName.split(' ')[0]}!',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigoAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to find your calm today?',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color:
                          theme.textTheme.bodyLarge?.color?.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSpecificContent(
      BuildContext context, WidgetRef ref, UserModel userModel) {
    final progressDataAsync =
    ref.watch(userProgressDataProvider(userModel.id!));
    return progressDataAsync.when(
      data: (progressData) {
        final levelProgress = GamificationUtils.getUserLevelProgress(
            userModel, progressData ?? ProgressDataModel(userId: userModel.id!));
        return GestureDetector(
          onTap: () => context.push('/levels'),
          child: _buildLevelProgressCard(context, levelProgress),
        );
      },
      loading: () => const SizedBox(height: 150, child: LoadingWidget()),
      error: (e, st) => Card(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Could not load progress: $e'))),
    );
  }

  Widget _buildRecommendations(
      BuildContext context, List<Recommendation> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('For You', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return SizedBox(
                width: 200,
                child: Card(
                  child: InkWell(
                    onTap: () => context.push(recommendation.route),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(recommendation.icon,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 8.0),
                          Text(recommendation.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4.0),
                          Expanded(
                            child: Text(
                              recommendation.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(
      BuildContext context, AsyncValue<QuoteModel?> quoteAsync) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      color: isDarkMode
          ? const Color(0xFF1E2A3A)
          : theme.colorScheme.primary.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: quoteAsync.when(
          data: (quote) {
            if (quote == null) {
              return const Text('Could not load quote today.');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_quote,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('Quote of the Day', style: AppTextStyles.titleLarge),
                  ],
                ),
                const SizedBox(height: 12),
                Text('"${quote.text}"', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('- ${quote.author}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontStyle: FontStyle.italic)),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
              height: 80, child: Center(child: CircularProgressIndicator())),
          error: (e, st) => const Text('Could not load quote today.'),
        ),
      ),
    );
  }

  Widget _buildLevelProgressCard(
      BuildContext context, UserLevelProgress levelProgress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Level ${levelProgress.currentLevel.levelNumber}: ${levelProgress.currentLevel.title}',
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(levelProgress.currentLevel.description,
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: levelProgress.progressPercentage,
              lineHeight: 12.0,
              barRadius: const Radius.circular(6),
              progressColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8.0,
              children: [
                TextButton.icon(
                  onPressed: () => context.push('/preferences'),
                  icon: const Icon(Icons.tune, size: 18),
                  label: const Text('Update Preferences'),
                  style: TextButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond_outlined,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(
                      '${levelProgress.currentGems} / ${levelProgress.nextLevel.gemsRequired} Gems',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(context, 'Breathing', Icons.air,
                () => context.push('/meditate/breathing')),
        _buildFeatureCard(context, 'Reading', Icons.auto_stories,
                () => context.push('/reading-therapy')),
        _buildFeatureCard(context, 'Music', Icons.music_note,
                () => context.push('/music-therapy')),
        _buildFeatureCard(context, 'Talk', Icons.chat_bubble,
                () => context.push('/chatbot')),
      ],
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.titleMedium),
          ],
        ),
      ),
    );
  }
}