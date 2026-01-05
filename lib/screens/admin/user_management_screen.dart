// lib/screens/admin/user_management_screen.dart
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/utils/helpers.dart';
import 'package:dhyana/models/user_model.dart';
import 'package:dhyana/providers/user_profile_provider.dart';
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:dhyana/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manage Users',
        showBackButton: true,
      ),
      body: allUsersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final hasProfileImage = user.profilePictureUrl != null && user.profilePictureUrl!.startsWith('http');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  // ✅ UPDATED: Display profile picture or initial
                  leading: CircleAvatar(
                    backgroundImage: hasProfileImage ? NetworkImage(user.profilePictureUrl!) : null,
                    child: !hasProfileImage && user.name.isNotEmpty
                        ? Text(user.name[0].toUpperCase())
                        : null,
                  ),
                  title: Text(user.name.isNotEmpty ? user.name : 'Unnamed User'),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRoleDropdown(context, ref, user),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit User Details',
                        onPressed: () {
                          context.push('/admin/edit-user', extra: user);
                        },
                      ),
                      // ✅ ADDED: Delete user icon button
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        tooltip: 'Delete User',
                        onPressed: () async {
                          final confirm = await Helpers.showConfirmationDialog(
                            context,
                            title: 'Delete User',
                            message: 'Are you sure you want to permanently delete ${user.name} and all their data?',
                            confirmText: 'Yes, Delete',
                          );
                          if (confirm == true && context.mounted) {
                            try {
                              await ref.read(userProfileNotifierProvider.notifier).deleteUser(user.id!);
                              if(context.mounted) {
                                Helpers.showSnackbar(context, 'User deleted successfully.');
                              }
                            } catch (e) {
                              if(context.mounted) {
                                Helpers.showMessageDialog(context, title: 'Error', message: 'Failed to delete user.');
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(message: 'Loading users...'),
        error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
      ),
    );
  }

  Widget _buildRoleDropdown(BuildContext context, WidgetRef ref, UserModel user) {
    const roles = ['user', 'admin'];

    return DropdownButton<String>(
      value: user.role,
      items: roles.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: AppTextStyles.bodyMedium),
        );
      }).toList(),
      onChanged: (String? newRole) async {
        if (newRole != null && newRole != user.role) {
          try {
            await ref.read(userProfileNotifierProvider.notifier).updateUserRole(user.id!, newRole);
            if (context.mounted) {
              Helpers.showSnackbar(context, "Successfully updated ${user.name}'s role to $newRole.");
            }
          } catch (e) {
            if (context.mounted) {
              Helpers.showMessageDialog(context, title: "Error", message: "Failed to update role.");
            }
          }
        }
      },
    );
  }
}