// lib/screens/admin/edit_user_screen.dart
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/core/utils/validators.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/providers/auth_provider.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/custom_button.dart';
import 'package:dhyana/widgets/common/custom_text_field.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditUserScreen({
    required this.user,
    super.key,
  });

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _currentRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _currentRole = widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        role: _currentRole,
      );

      await ref.read(userProfileNotifierProvider.notifier).updateUserProfile(updatedUser);

      if (mounted) {
        context.pop(); // Go back to the user list
        Helpers.showSnackbar(context, '${updatedUser.name}\'s profile has been updated.');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(context, title: 'Error', message: 'Failed to update user profile.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSendPasswordReset() async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Confirm Action',
      message: 'This will send a password reset link to ${widget.user.email}. Do you want to proceed?',
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).resetPassword(widget.user.email);
      if (mounted) {
        Helpers.showSnackbar(context, 'Password reset email sent successfully.');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(context, title: 'Error', message: 'Failed to send reset email: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ ADDED: Handler for deleting the user
  Future<void> _handleDeleteUser() async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete User',
      message: 'Are you sure you want to permanently delete this user and all their data? This action cannot be undone.',
      confirmText: 'Yes, Delete',
    );
    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userProfileNotifierProvider.notifier).deleteUser(widget.user.id!);
      if (mounted) {
        context.pop(); // Go back to the user list
        Helpers.showSnackbar(context, 'User ${widget.user.name} has been deleted.');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showMessageDialog(context, title: 'Error', message: 'Failed to delete user: ${e.toString()}');
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
      appBar: const CustomAppBar(
        title: 'Edit User Profile',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'User Name',
                validator: (value) => Validators.isValidName(value),
              ),
              const SizedBox(height: 16),
              Text('Email: ${widget.user.email}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _currentRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: ['user', 'admin'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentRole = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const LoadingWidget()
              else
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _handleSaveChanges,
                  icon: Icons.save_outlined,
                ),
              const Divider(height: 48),
              Text(
                'Danger Zone',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Send Password Reset',
                onPressed: _isLoading ? (){} : _handleSendPasswordReset,
                icon: Icons.email_outlined,
                type: ButtonType.secondary,
              ),
              const SizedBox(height: 16),
              // ✅ ADDED: Delete user button
              CustomButton(
                text: 'Delete User',
                onPressed: _isLoading ? (){} : _handleDeleteUser,
                icon: Icons.delete_forever_outlined,
                type: ButtonType.secondary,
                // You can add a specific style for delete buttons in your CustomButton
                // or use a different button type if you want it to be red.
              ),
            ],
          ),
        ),
      ),
    );
  }
}