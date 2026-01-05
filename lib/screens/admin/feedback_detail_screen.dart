// lib/screens/admin/feedback_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhyana/models/feedback_model.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackDetailScreen extends StatelessWidget {
  final FeedbackModel feedback;

  const FeedbackDetailScreen({required this.feedback, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Feedback Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.type,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'From User: ${feedback.userId}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Submitted on: ${DateFormat.yMMMd().add_jm().format(feedback.timestamp)}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Message:',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: theme.dividerColor),
              ),
              child: SelectableText(
                feedback.message,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ),
            if (feedback.imageUrl != null && feedback.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              Text(
                'Attached Image:',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: feedback.imageUrl!,
                  placeholder: (context, url) => const LoadingWidget(),
                  errorWidget: (context, url, error) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Could not load image.'),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}