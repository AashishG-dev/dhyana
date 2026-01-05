// lib/widgets/cards/music_track_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhyana/models/music_track_model.dart';
import 'package:flutter/material.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';

class MusicTrackCard extends StatelessWidget {
  final MusicTrackModel track;
  final VoidCallback onTap;

  const MusicTrackCard({
    required this.track,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Check if the imageUrl is valid and is a network URL
    final bool hasValidImage =
        track.imageUrl != null && track.imageUrl!.startsWith('http');

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 180,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                ),
                child: hasValidImage
                    ? CachedNetworkImage( // Use CachedNetworkImage for better performance
                  imageUrl: track.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.music_note, color: Colors.grey, size: 40),
                  ),
                )
                    : const Center(
                  child: Icon(Icons.music_note, color: Colors.grey, size: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      style: AppTextStyles.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artist,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: (isDark
                            ? AppColors.textDark
                            : AppColors.textLight)
                            .withAlpha(179), // Fixed deprecated withOpacity
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}