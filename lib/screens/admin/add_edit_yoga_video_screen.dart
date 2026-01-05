// lib/screens/admin/add_edit_yoga_video_screen.dart
import 'package:dhyana/models/yoga_video_model.dart';
import 'package:dhyana/providers/yoga_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddEditYogaVideoScreen extends ConsumerStatefulWidget {
  final YogaVideoModel? video;
  const AddEditYogaVideoScreen({super.key, this.video});

  @override
  ConsumerState<AddEditYogaVideoScreen> createState() => _AddEditYogaVideoScreenState();
}

class _AddEditYogaVideoScreenState extends ConsumerState<AddEditYogaVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.video != null) {
      _titleController.text = widget.video!.title;
      _descriptionController.text = widget.video!.description;
      _videoUrlController.text = 'https://www.youtube.com/watch?v=${widget.video!.videoId}';
    }
  }

  String? _extractVideoId(String url) {
    if (!url.contains("youtube.com/") && !url.contains("youtu.be/")) {
      return null;
    }
    RegExp regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|watch\?v=)|&v=)([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(1) != null && match.group(1)!.length == 11)
        ? match.group(1)
        : null;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final videoId = _extractVideoId(_videoUrlController.text.trim());
      if (videoId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid YouTube URL.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        final video = YogaVideoModel(
          id: widget.video?.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          videoId: videoId,
          thumbnailUrl: 'https://img.youtube.com/vi/$videoId/0.jpg',
        );

        final notifier = ref.read(yogaNotifierProvider.notifier);
        if (widget.video == null) {
          await notifier.addYogaVideo(video);
        } else {
          await notifier.updateYogaVideo(video);
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
        title: widget.video == null ? 'Add Yoga Video' : 'Edit Yoga Video',
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
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(labelText: 'YouTube Video Link'),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a link';
                  if (_extractVideoId(value) == null) return 'Invalid YouTube link';
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