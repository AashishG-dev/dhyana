// lib/screens/admin/manage_standup_screen.dart
import 'package:dhyana/models/standup_video_model.dart';
import 'package:dhyana/providers/laughing_therapy_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageStandupScreen extends ConsumerStatefulWidget {
  final StandupVideoModel? video;
  const ManageStandupScreen({super.key, this.video});

  @override
  ConsumerState<ManageStandupScreen> createState() => _ManageStandupScreenState();
}

class _ManageStandupScreenState extends ConsumerState<ManageStandupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _videoUrlController = TextEditingController(); // Renamed for clarity
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.video != null) {
      _titleController.text = widget.video!.title;
      _artistController.text = widget.video!.artist;
      // When editing, show the full watch URL for consistency
      _videoUrlController.text = 'https://www.youtube.com/watch?v=${widget.video!.videoId}';
    }
  }

  // ✅ ADDED: Helper function to extract YouTube Video ID from various URL formats
  String? _extractVideoId(String url) {
    if (!url.contains("youtube.com/") && !url.contains("youtu.be/")) {
      return null; // Not a youtube link
    }
    RegExp regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|watch\?v=)|&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    // The video ID is in the first capturing group
    return (match != null && match.group(1) != null && match.group(1)!.length == 11)
        ? match.group(1)
        : null;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Extract the video ID from the URL
      final videoId = _extractVideoId(_videoUrlController.text.trim());
      if (videoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid YouTube URL. Please check the link.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        final video = StandupVideoModel(
          id: widget.video?.id,
          title: _titleController.text.trim(),
          artist: _artistController.text.trim(),
          videoId: videoId, // Use the extracted ID
          thumbnailUrl: 'https://img.youtube.com/vi/$videoId/0.jpg',
          createdAt: widget.video?.createdAt,
        );

        final notifier = ref.read(laughingTherapyNotifierProvider.notifier);
        if (widget.video == null) {
          await notifier.addStandupVideo(video);
        } else {
          await notifier.updateStandupVideo(video);
        }

        if (mounted) context.pop();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.video == null ? 'Add Stand-up' : 'Edit Stand-up',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artist'),
                validator: (value) => value!.isEmpty ? 'Please enter an artist' : null,
              ),
              const SizedBox(height: 16),
              // ✅ UPDATED: Changed the field to accept a full URL
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video Link',
                  hintText: 'e.g., https://www.youtube.com/watch?v=...',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a YouTube link';
                  }
                  if (_extractVideoId(value) == null) {
                    return 'Please enter a valid YouTube link';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const LoadingWidget()
                  : CustomButton(
                text: 'Save Video',
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}