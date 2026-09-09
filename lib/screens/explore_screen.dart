import 'package:flutter/material.dart';

import '../controllers/goal_controller.dart';
import '../models/goal.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen(
      {super.key, required this.controller, required this.onEdit});

  final GoalController controller;
  final ValueChanged<Goal> onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(title: Text('Trail review'), pinned: true),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.list(
                children: [
                  Text(
                    controller.goals.isEmpty
                        ? 'Your progress story starts with the first goal.'
                        : '${controller.completedGoals.length} summits reached across ${controller.goals.length} goals.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  _OverallProgress(controller: controller),
                  const SizedBox(height: 32),
                  Text('By area',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...GoalCategory.values.map(
                    (category) => _CategoryProgress(
                      category: category,
                      goals: controller.goals
                          .where((goal) => goal.category == category)
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Completed goals',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (controller.completedGoals.isEmpty)
                    _ReviewEmpty(hasGoals: controller.goals.isNotEmpty)
                  else
                    ...controller.completedGoals.map(
                      (goal) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        leading: Icon(Icons.flag,
                            color: Theme.of(context).colorScheme.primary),
                        title: Text(goal.title),
                        subtitle: Text(goal.category.label),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: controller.isSaving ? null : () => onEdit(goal),
                      ),
                    ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({required this.controller});

  final GoalController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alt_route, color: scheme.onTertiaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Across the whole trail',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: scheme.onTertiaryContainer),
                ),
              ),
              Text(
                '${controller.averageProgress}%',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: scheme.onTertiaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: controller.averageProgress / 100,
              minHeight: 10,
              color: scheme.tertiary,
              backgroundColor: scheme.surface.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.goals.isEmpty
                ? 'Add a goal to begin.'
                : '${controller.activeGoals.length} active  •  ${controller.completedGoals.length} completed',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onTertiaryContainer),
          ),
        ],
      ),
    );
  }
}

class _CategoryProgress extends StatelessWidget {
  const _CategoryProgress({required this.category, required this.goals});

  final GoalCategory category;
  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    final progress = goals.isEmpty
        ? 0
        : (goals.fold<int>(0, (sum, goal) => sum + goal.progress) /
                goals.length)
            .round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 82, child: Text(category.label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text('$progress%', textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _ReviewEmpty extends StatelessWidget {
  const _ReviewEmpty({required this.hasGoals});

  final bool hasGoals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.outlined_flag),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              hasGoals
                  ? 'Keep moving. A goal appears here when it reaches 100%.'
                  : 'Create a goal from the Goals tab, then update its progress as you move.',
            ),
          ),
        ],
      ),
    );
  }
}
