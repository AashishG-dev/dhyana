// lib/screens/admin/admin_portal_screen.dart
import 'package:dhyana/widgets/common/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPortalScreen extends StatelessWidget {
  const AdminPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Portal',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAdminCard(
            context: context,
            title: 'Manage Articles',
            subtitle: 'Create, edit, and delete articles',
            icon: Icons.article_outlined,
            onTap: () => context.push('/admin/articles'),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context: context,
            title: 'Manage Users',
            subtitle: 'View users and manage roles',
            icon: Icons.people_outline,
            onTap: () => context.push('/admin/users'),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context: context,
            title: 'Manage Laughing Therapy',
            subtitle: 'Add, edit, and delete memes and videos',
            icon: Icons.emoji_emotions_outlined,
            onTap: () => context.push('/admin/laughing-therapy'),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context: context,
            title: 'Manage Yoga Therapy',
            subtitle: 'Add, edit, and delete yoga videos',
            icon: Icons.self_improvement_outlined,
            onTap: () => context.push('/admin/manage-yoga-therapy'),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context: context,
            title: 'Manage Feedback',
            subtitle: 'View and delete user feedback',
            icon: Icons.feedback_outlined,
            onTap: () => context.push('/admin/feedback'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        contentPadding: const EdgeInsets.all(16.0),
        onTap: onTap,
      ),
    );
  }
}