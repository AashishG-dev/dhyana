// lib/screens/settings/feedback_screen.dart
import 'dart:io';
import 'package:dhyana/core/services/cloudinary_service.dart';
import 'package:dhyana/models/feedback_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _feedbackType = 'General Feedback';
  bool _isLoading = false;
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = ref.read(currentUserProfileProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to submit feedback.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        String? imageUrl;
        if (_imageFile != null) {
          final cloudinaryService = ref.read(cloudinaryServiceProvider);
          imageUrl = await cloudinaryService.uploadFile(
            filePath: _imageFile!.path,
            resourceType: CloudinaryResourceType.image,
            folder: 'feedback_attachments',
          );
          if (imageUrl == null) {
            throw Exception('Image upload failed.');
          }
        }

        final feedback = FeedbackModel(
          userId: user.id!,
          type: _feedbackType,
          message: _messageController.text,
          timestamp: DateTime.now(),
          imageUrl: imageUrl,
        );

        await ref.read(firestoreServiceProvider).addFeedback(feedback);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thank you for your feedback!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit feedback: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Send Feedback',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feedback Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                onChanged: (String? newValue) {
                  setState(() {
                    _feedbackType = newValue!;
                  });
                },
                items: <String>[
                  'General Feedback',
                  'Bug Report',
                  'Feature Request',
                  'Other'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Your Message',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _messageController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Tell us what you think...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Text(
                'Attach an Image (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(11.0),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to select an image'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: LoadingWidget())
                  : CustomButton(
                text: 'Submit Feedback',
                onPressed: _submitFeedback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}