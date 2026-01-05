// lib/screens/admin/feedback_management_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dhyana/models/feedback_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final feedbackProvider = StreamProvider<List<FeedbackModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getFeedback();
});

class FeedbackManagementScreen extends ConsumerWidget {
  const FeedbackManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(feedbackProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Feedback',
        showBackButton: true,
      ),
      body: feedbackAsync.when(
        data: (feedbackList) {
          if (feedbackList.isEmpty) {
            return const Center(child: Text('No feedback yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: feedbackList.length,
            itemBuilder: (context, index) {
              final feedback = feedbackList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  title: Text(feedback.type, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(
                    feedback.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref
                          .read(firestoreServiceProvider)
                          .deleteFeedback(feedback.id!);
                    },
                  ),
                  onTap: () {
                    context.push('/admin/feedback-detail', extra: feedback);
                  },
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}