// lib/screens/admin/manage_meme_screen.dart
import 'dart:io';
import 'package:dhyana/core/services/cloudinary_service.dart';
import 'package:dhyana/models/meme_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/laughing_therapy_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ManageMemeScreen extends ConsumerStatefulWidget {
  final MemeModel? meme;
  const ManageMemeScreen({super.key, this.meme});

  @override
  ConsumerState<ManageMemeScreen> createState() => _ManageMemeScreenState();
}

class _ManageMemeScreenState extends ConsumerState<ManageMemeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  File? _imageFile;
  String? _networkImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.meme != null) {
      _captionController.text = widget.meme!.caption ?? '';
      _networkImageUrl = widget.meme!.imageUrl;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      // An image must be present, either a new one or an existing one
      if (_imageFile == null && _networkImageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image.')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        String imageUrl = _networkImageUrl ?? '';

        // If a new image file was selected, upload it to Cloudinary
        if (_imageFile != null) {
          final cloudinaryService = ref.read(cloudinaryServiceProvider);
          final uploadedUrl = await cloudinaryService.uploadFile(
            filePath: _imageFile!.path,
            resourceType: CloudinaryResourceType.image,
            folder: 'memes', // Optional: organize uploads into folders
          );
          if (uploadedUrl == null) {
            throw Exception('Image upload to Cloudinary failed.');
          }
          imageUrl = uploadedUrl;
        }

        final meme = MemeModel(
          id: widget.meme?.id,
          imageUrl: imageUrl, // Save the Cloudinary URL
          caption: _captionController.text.trim(),
          createdAt: widget.meme?.createdAt, // Preserve original creation date on edit
        );

        final notifier = ref.read(laughingTherapyNotifierProvider.notifier);
        if (widget.meme == null) {
          await notifier.addMeme(meme);
        } else {
          await notifier.updateMeme(meme);
        }

        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving meme: $e'))
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.meme == null ? 'Add Meme' : 'Edit Meme',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : _networkImageUrl != null
                      ? Image.network(_networkImageUrl!, fit: BoxFit.cover)
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to select an image'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const LoadingWidget()
                  : CustomButton(
                text: 'Save Meme',
                onPressed: _handleSave,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}