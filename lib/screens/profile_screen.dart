import 'package:flutter/material.dart';

import '../controllers/goal_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.controller,
    this.crashReporting = false,
  });

  final GoalController controller;

  /// True when this build sends crash reports (see crash_reporting.dart).
  final bool crashReporting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(title: Text('Settings'), pinned: true),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
              sliver: SliverList.list(
                children: [
                  _InfoPanel(
                    icon: Icons.cloud_off_outlined,
                    title: 'Private by default',
                    body: crashReporting
                        ? 'Goals stay on this device. There is no account, advertising, analytics, or cloud sync. If the app crashes, it sends a crash report to Sentry with the error type and where in the code it happened, never your goals or personal details.'
                        : 'Goals stay on this device. There is no account, advertising, analytics, or cloud sync.',
                  ),
                  const SizedBox(height: 12),
                  _InfoPanel(
                    icon: Icons.dark_mode_outlined,
                    title: 'Follows your device',
                    body:
                        'Goal Tracker uses your Android light or dark appearance setting.',
                  ),
                  const SizedBox(height: 28),
                  Text('About', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(Icons.landscape_outlined),
                    title: Text('Goal Tracker'),
                    subtitle: Text('Version 1.0.0'),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(Icons.storage_outlined),
                    title: Text('Storage'),
                    subtitle: Text('Local app preferences on this device'),
                  ),
                  const SizedBox(height: 40),
                  Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  const SizedBox(height: 24),
                  Text('Your local data',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.goals.length} goals are stored on this device. Clearing them cannot be undone.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: controller.goals.isEmpty || controller.isSaving
                        ? null
                        : () => _confirmClear(context),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Clear all goals'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_sweep_outlined),
        title: const Text('Clear every goal?'),
        content: const Text(
            'All goals and progress will be removed from this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success = await controller.clearAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
            content:
                Text(success ? 'All goals cleared' : 'Goals were not cleared')),
      );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel(
      {required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
