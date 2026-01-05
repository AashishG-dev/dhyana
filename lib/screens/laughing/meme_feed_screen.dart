// lib/screens/laughing/meme_feed_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/providers/laughing_therapy_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemeFeedScreen extends ConsumerWidget {
  const MemeFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memesAsync = ref.watch(memesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(
        title: 'Fresh Memes',
        showBackButton: true,
      ),
      body: memesAsync.when(
        data: (memes) {
          if (memes.isEmpty) {
            return const Center(
              child: Text('No memes have been uploaded yet.', style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.builder(
            itemCount: memes.length,
            itemBuilder: (context, index) {
              final meme = memes[index];
              return Card(
                color: const Color(0xFF121212),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      meme.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                    if (meme.caption != null && meme.caption!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          meme.caption!,
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.errorColor))),
      ),
    );
  }
}