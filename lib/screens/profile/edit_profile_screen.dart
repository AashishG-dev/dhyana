// lib/screens/profile/edit_profile_screen.dart
import 'dart:io';
import 'package:dhyana/core/services/cloudinary_service.dart';
import 'package:dhyana/core/services/task_completion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile; // To hold the selected image file

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field with the user's current name
    final userProfile = ref.read(currentUserProfileProvider).value;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Function to open the image gallery and pick an image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleUpdateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) {
        if (mounted) {
          Helpers.showMessageDialog(context,
              title: 'Error', message: 'User profile not found.');
        }
        setState(() => _isLoading = false);
        return;
      }

      try {
        String? newProfilePictureUrl = userProfile.profilePictureUrl;

        // If a new image was selected, upload it to Cloudinary
        if (_imageFile != null) {
          final cloudinaryService = ref.read(cloudinaryServiceProvider);
          final uploadedUrl = await cloudinaryService.uploadFile(
            filePath: _imageFile!.path,
            resourceType: CloudinaryResourceType.image,
            folder: 'profile_pictures', // Keep uploads organized
          );
          if (uploadedUrl == null) throw Exception('Image upload failed.');
          newProfilePictureUrl = uploadedUrl;
        }

        // Create the updated user model
        final updatedUser = userProfile.copyWith(
          name: _nameController.text.trim(),
          profilePictureUrl: newProfilePictureUrl,
        );

        // Update the profile in Firestore
        await ref
            .read(userProfileNotifierProvider.notifier)
            .updateUserProfile(updatedUser);

        // Mark the 'complete_profile' task as complete
        ref.read(taskCompletionServiceProvider).completeTask('complete_profile');

        if (mounted) {
          Helpers.showSnackbar(context, 'Profile updated successfully!');
          context.go('/levels');
        }
      } catch (e) {
        debugPrint('Update Profile Error: $e');
        if (mounted) {
          Helpers.showMessageDialog(context,
              title: 'Update Failed',
              message: 'An error occurred. Please try again.');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile', showBackButton: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.backgroundDark, const Color(0xFF212121)]
                : [AppColors.backgroundLight, const Color(0xFFEEEEEE)],
          ),
        ),
        child: userProfileAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('User profile not found'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Tappable CircleAvatar for image selection
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: isDarkMode
                                ? AppColors.primaryLightGreen.withAlpha(51)
                                : AppColors.primaryLightBlue.withAlpha(51),
                            // Show the newly selected image, fallback to network image, then to initial
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : (user.profilePictureUrl != null &&
                                user.profilePictureUrl!
                                    .startsWith('http'))
                                ? NetworkImage(user.profilePictureUrl!)
                                : null as ImageProvider?,
                            child: (_imageFile == null &&
                                (user.profilePictureUrl == null ||
                                    !user.profilePictureUrl!
                                        .startsWith('http')))
                                ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: isDarkMode
                                    ? AppColors.primaryLightGreen
                                    : AppColors.primaryLightBlue,
                              ),
                            )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.edit,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    Text(
                      'Update Your Details',
                      style: AppTextStyles.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Your Name',
                      keyboardType: TextInputType.name,
                      validator: (value) =>
                          Validators.isValidName(value, minLength: 2),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Email: ${user.email}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(179),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 2),
                    _isLoading
                        ? const LoadingWidget()
                        : CustomButton(
                      text: 'Save Changes',
                      onPressed: _handleUpdateProfile,
                      type: ButtonType.primary,
                      icon: Icons.save_outlined,
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: LoadingWidget()),
          error: (error, stack) =>
              Center(child: Text('Error loading profile: ${error.toString()}')),
        ),
      ),
    );
  }
}