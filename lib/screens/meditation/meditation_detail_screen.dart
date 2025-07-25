// lib/screens/meditation/meditation_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/providers/meditation_provider.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:intl/intl.dart';

class MeditationDetailScreen extends ConsumerWidget {
  final String meditationId;
  const MeditationDetailScreen({required this.meditationId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meditationAsync = ref.watch(meditationByIdProvider(meditationId));
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      body: meditationAsync.when(
        data: (meditation) {
          if (meditation == null) {
            return const Center(child: Text('Meditation not found.'));
          }

          final isFavorite = userProfileAsync.when(
            data: (user) => user?.favoriteMeditationIds.contains(meditationId) ?? false,
            loading: () => false,
            error: (e, s) => false,
          );

          final formattedPlayCount = NumberFormat.compact().format(meditation.playCount);

          return Stack(
            children: [
              if (meditation.imageUrl != null && meditation.imageUrl!.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    meditation.imageUrl!,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      // ✅ FIX: Disable button while user profile is loading to prevent crash
                      userProfileAsync.when(
                        data: (user) => IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.redAccent : Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            if (user != null && user.id != null) {
                              ref.read(userProfileNotifierProvider.notifier).toggleFavoriteMeditation(user.id!, meditationId);
                            }
                          },
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)),
                        ),
                        error: (e,s) => const Icon(Icons.error, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meditation.title, style: AppTextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Row(
                        children: [
                          _buildTag('${meditation.durationMinutes} min'),
                          _buildTag(meditation.voiceType),
                          _buildTag(meditation.category),
                        ],
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        meditation.description,
                        style: AppTextStyles.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        '$formattedPlayCount plays',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.7)),
                      ),
                      const SizedBox(height: AppConstants.paddingLarge * 2),
                      CustomButton(
                        text: 'Begin',
                        onPressed: () {
                          context.push('/meditation-player/${meditation.id}');
                        },
                        type: ButtonType.primary,
                        icon: Icons.play_arrow,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading Meditation...'),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      margin: const EdgeInsets.only(right: AppConstants.marginSmall),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3))
      ),
      child: Text(text, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
    );
  }
}