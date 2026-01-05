// lib/screens/admin/manage_article_screen.dart
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/models/article_model.dart';
import 'package:dhyana/providers/article_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageArticleScreen extends ConsumerStatefulWidget {
  final ArticleModel? article;

  const ManageArticleScreen({
    super.key,
    this.article,
  });

  @override
  ConsumerState<ManageArticleScreen> createState() => _ManageArticleScreenState();
}

class _ManageArticleScreenState extends ConsumerState<ManageArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _authorController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _readingTimeController = TextEditingController();
  final _geminiPromptController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;

  bool get isEditMode => widget.article != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadArticleForEditing();
    }
  }

  Future<void> _loadArticleForEditing() async {
    final article = widget.article!;
    _titleController.text = article.title;
    _categoryController.text = article.category;
    _authorController.text = article.author;
    _imageUrlController.text = article.imageUrl ?? '';
    _readingTimeController.text = article.readingTimeMinutes.toString();

    // Fetch the full content for editing
    final content = await ref.read(articleContentProvider(article.id!).future);
    _contentController.text = content ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _authorController.dispose();
    _imageUrlController.dispose();
    _readingTimeController.dispose();
    _geminiPromptController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerateContent() async {
    FocusScope.of(context).unfocus(); // Hide keyboard
    if (_geminiPromptController.text.trim().isEmpty) {
      Helpers.showSnackbar(context, 'Please enter a prompt for Gemini.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final generatedData = await ref
          .read(articleNotifierProvider.notifier)
          .generateArticleContent(_geminiPromptController.text.trim());

      // Populate the form fields with the data from Gemini
      _titleController.text = generatedData['title'] ?? '';
      _categoryController.text = generatedData['category'] ?? '';
      _authorController.text = generatedData['author'] ?? '';
      _imageUrlController.text = generatedData['imageUrl'] ?? '';
      _readingTimeController.text = (generatedData['readingTimeMinutes'] ?? 0).toString();
      _contentController.text = generatedData['content'] ?? '';

    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(context, title: 'Error', message: 'Failed to generate content: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSaveArticle() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Create an ArticleModel instance from the form data
      final article = ArticleModel(
        id: widget.article?.id,
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        author: _authorController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        readingTimeMinutes: int.tryParse(_readingTimeController.text.trim()) ?? 0,
        publishedAt: isEditMode ? widget.article!.publishedAt : DateTime.now(),
        content: _contentController.text.trim(),
      );

      final notifier = ref.read(articleNotifierProvider.notifier);
      if (isEditMode) {
        await notifier.updateArticle(article);
      } else {
        await notifier.addArticle(article);
      }

      if (mounted) {
        // Pop twice to go back to the article list, not the portal hub
        context.pop();
        Helpers.showSnackbar(context, isEditMode ? 'Article updated!' : 'Article created!');
      }

    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(context, title: 'Error', message: 'Failed to save article: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditMode ? 'Edit Article' : 'Create Article',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Generate Content with AI',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _geminiPromptController,
                decoration: const InputDecoration(
                  labelText: 'Gemini Prompt',
                  hintText: 'e.g., "Write an article about the benefits of meditation for beginners"',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleGenerateContent,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Article Content'),
              ),
              const Divider(height: 32),
              Text(
                'Article Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) => Validators.isNotEmpty(value, fieldName: 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                validator: (value) => Validators.isNotEmpty(value, fieldName: 'Category'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author', border: OutlineInputBorder()),
                validator: (value) => Validators.isNotEmpty(value, fieldName: 'Author'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _readingTimeController,
                decoration: const InputDecoration(labelText: 'Reading Time (Minutes)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.isNotEmpty(value, fieldName: 'Reading Time'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Full Content (Markdown)',
                  hintText: 'This will be filled by Gemini, or you can edit it manually.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 15,
                validator: (value) => Validators.isNotEmpty(value, fieldName: 'Content'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveArticle,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditMode ? 'Save Changes' : 'Create Article'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}