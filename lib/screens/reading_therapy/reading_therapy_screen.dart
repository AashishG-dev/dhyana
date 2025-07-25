// lib/screens/reading_therapy/reading_therapy_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:dhyana/widgets/cards/article_card.dart';
// ✅ ADD: Import the missing ArticleModel.
import 'package:dhyana/models/article_model.dart';

class ReadingTherapyScreen extends ConsumerWidget {
  const ReadingTherapyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.backgroundDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text('Reading Therapy', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const NetworkImage('https://images.unsplash.com/photo-1521587760476-6c12a4b040da?q=80&w=2070&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Find happiness, knowledge, and lighten your stress side by side.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionTitle('Benefits of Reading', isDarkMode),
              _buildBenefitsCard(),
              _buildSectionTitle('Inspirational Stories', isDarkMode),
              articlesAsync.when(
                data: (articles) {
                  if (articles.isEmpty) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No articles available.')));
                  }
                  return _buildHorizontalArticleList(context, articles);
                },
                loading: () => const SizedBox(height: 250, child: LoadingWidget()),
                error: (e, st) => Center(child: Text('Error: $e')),
              ),
              _buildSectionTitle('Motivational Quotes', isDarkMode),
              _buildHorizontalQuoteList(),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: isDarkMode ? AppColors.textDark : AppColors.textLight,
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bibliotherapy', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
             Text(
              'Also referred to as book therapy, is a creative arts therapy that uses storytelling or the reading of specific texts. It uses an individual\'s relationship to the content of books and poetry and other written words as therapy.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalArticleList(BuildContext context, List<ArticleModel> articles) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 220,
            child: ArticleCard(
              article: articles[index],
              onTap: () => context.push('/article-detail/${articles[index].id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalQuoteList() {
    final quotes = [
      {'quote': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs'},
      {'quote': 'Believe you can and you\'re halfway there.', 'author': 'Theodore Roosevelt'},
      {'quote': 'The future belongs to those who believe in the beauty of their dreams.', 'author': 'Eleanor Roosevelt'},
    ];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('"${quotes[index]['quote']}"', style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('- ${quotes[index]['author']}', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}