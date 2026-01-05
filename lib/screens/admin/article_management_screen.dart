// lib/screens/admin/article_management_screen.dart
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ArticleManagementScreen extends ConsumerWidget {
  const ArticleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This provider gives us the real-time list of all articles
    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Articles',
        showBackButton: true,
      ),
      body: articlesAsync.when(
        data: (groupedArticles) {
          // We flatten the map of categories into a single list for display
          final allArticles = groupedArticles.values.expand((list) => list).toList()
            ..sort((a, b) => (b.publishedAt ?? DateTime(0)).compareTo(a.publishedAt ?? DateTime(0)));

          if (allArticles.isEmpty) {
            return const Center(child: Text('No articles found. Tap the + button to create one.'));
          }

          return ListView.builder(
            itemCount: allArticles.length,
            itemBuilder: (context, index) {
              final article = allArticles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(article.title, style: AppTextStyles.titleMedium),
                  subtitle: Text('Category: ${article.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.infoColor),
                        tooltip: 'Edit Article',
                        onPressed: () {
                          context.push('/manage-article', extra: article);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                        tooltip: 'Delete Article',
                        onPressed: () async {
                          // Show a confirmation dialog before deleting
                          final confirm = await Helpers.showConfirmationDialog(
                            context,
                            title: 'Delete Article',
                            message: 'Are you sure you want to permanently delete "${article.title}"?',
                            confirmText: 'Yes, Delete',
                          );

                          if (confirm == true) {
                            try {
                              await ref.read(articleNotifierProvider.notifier).deleteArticle(article.id!);
                              if (context.mounted) {
                                Helpers.showSnackbar(context, 'Article deleted successfully.');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Helpers.showMessageDialog(context, title: 'Error', message: 'Failed to delete article.');
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading articles...'),
        error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/manage-article');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}