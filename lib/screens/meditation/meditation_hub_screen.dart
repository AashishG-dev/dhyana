// lib/screens/meditation/meditation_hub_screen.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:dhyana/models/therapy_card_model.dart';
import 'package:dhyana/providers/music_provider.dart';
import 'package:dhyana/widgets/common/mini_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/bottom_nav_bar.dart';
import 'package:dhyana/widgets/common/profile_avatar.dart';

class MeditationHubScreen extends ConsumerWidget {
  const MeditationHubScreen({super.key});

  static const List<TherapyCardModel> _therapyOptions = [
    TherapyCardModel(
      title: 'Breathing Techniques',
      description: 'Calm your mind with guided breathing patterns.',
      imageAsset: 'assets/images/breathing.png',
      route: '/meditate/breathing',
    ),
    TherapyCardModel(
      title: 'Reading Therapy',
      description: 'Find calm and inspiration through words.',
      imageAsset: 'assets/images/reading.png',
      route: '/reading-therapy',
    ),
    TherapyCardModel(
      title: 'Music Therapy',
      description: 'Relax with a collection of calming soundscapes.',
      imageAsset: 'assets/images/music.png',
      route: '/music-therapy',
    ),
    TherapyCardModel(
      title: 'Yoga Therapy',
      description: 'Yoga and exercise play a very important role.',
      imageAsset: 'assets/images/yoga.png',
      route: '/yoga',
      isEnabled: true,
    ),
    TherapyCardModel(
      title: 'Talking Therapy',
      description: 'A quick short conversation can bring a smile.',
      imageAsset: 'assets/images/talking.png',
      route: '/chatbot',
    ),
    TherapyCardModel(
      title: 'Laughing Therapy',
      description: 'Laughing is the only medicine which refreshes.',
      imageAsset: 'assets/images/laughing.png',
      route: '/laughing',
      isEnabled: true,
    ),
    TherapyCardModel(
      title: 'Spiritual Therapy',
      description: 'Helps you to become more mindful in your thinking.',
      imageAsset: 'assets/images/spiritual.png',
      route: '/spiritual',
      isEnabled: false,
    ),
    TherapyCardModel(
      title: 'Doctors Consultant',
      description: 'Get professional help from licensed therapists.',
      imageAsset: 'assets/images/doctor.png', // Make sure this asset exists
      route: '/consultant',
      isEnabled: false, // Set to false for "Coming Soon"
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final musicPlayerState = ref.watch(musicPlayerProvider);
    final shouldShowMiniPlayer = musicPlayerState.currentTrack != null &&
        (musicPlayerState.playerState == PlayerState.playing ||
            musicPlayerState.playerState == PlayerState.paused);

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisSpacing = AppConstants.marginMedium;
    final cardWidth =
        (screenWidth - (AppConstants.paddingMedium * 2) - crossAxisSpacing) /
            2;
    final cardHeight = cardWidth / 0.7;
    final childAspectRatio = cardWidth / cardHeight;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        // Use the new signature
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Begin Your Practice',
          showBackButton: true,
          actions: [ProfileAvatar()],
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
          child: GridView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: AppConstants.marginMedium,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _therapyOptions.length,
            itemBuilder: (context, index) {
              final option = _therapyOptions[index];
              return _buildHubCard(
                context: context,
                option: option,
              );
            },
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shouldShowMiniPlayer) const MiniMusicPlayer(),
            const CustomBottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildHubCard({
    required BuildContext context,
    required TherapyCardModel option,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF232D3F) : Colors.white;

    return Opacity(
      opacity: option.isEnabled ? 1.0 : 0.6,
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: option.isEnabled ? () => context.push(option.route) : null,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(option.imageAsset),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        option.title,
                        style: AppTextStyles.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: (isDarkMode
                              ? AppColors.textDark
                              : AppColors.textLight)
                              .withAlpha(179),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!option.isEnabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Coming Soon',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.primaryLightGreen),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}