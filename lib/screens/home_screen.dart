import 'package:flutter/material.dart';

import '../controllers/goal_controller.dart';
import '../models/goal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller, required this.onEdit});

  final GoalController controller;
  final ValueChanged<Goal> onEdit;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoalCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: controller.isLoading
            ? const _LoadingTrail()
            : controller.errorMessage != null && controller.goals.isEmpty
                ? _LoadError(controller: controller)
                : RefreshIndicator(
                    onRefresh: controller.load,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverAppBar.large(
                          title: Text('Goal Tracker'),
                          pinned: true,
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            child: _TrailOverview(controller: controller),
                          ),
                        ),
                        if (controller.goals.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _CategoryFilter(
                              selected: _filter,
                              onSelected: (value) =>
                                  setState(() => _filter = value),
                            ),
                          ),
                        ..._goalSlivers(context),
                        const SliverToBoxAdapter(child: SizedBox(height: 112)),
                      ],
                    ),
                  ),
      ),
    );
  }

  List<Widget> _goalSlivers(BuildContext context) {
    final allGoals = widget.controller.goals;
    final filtered = _filter == null
        ? allGoals
        : allGoals.where((goal) => goal.category == _filter).toList();
    final active = filtered.where((goal) => !goal.isComplete).toList();
    final completed = filtered.where((goal) => goal.isComplete).toList();

    if (allGoals.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyGoals(onAdd: () => _showAddHint(context)),
        ),
      ];
    }

    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_alt_off_outlined,
                      size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('No goals in this category',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _filter = null),
                    child: const Text('Show all goals'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      if (active.isNotEmpty) _sectionTitle('On the trail', active.length),
      if (active.isNotEmpty) _goalList(active),
      if (completed.isNotEmpty)
        _sectionTitle('Summits reached', completed.length),
      if (completed.isNotEmpty) _goalList(completed),
    ];
  }

  Widget _sectionTitle(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
        child: Row(
          children: [
            Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleLarge)),
            Text('$count', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _goalList(List<Goal> goals) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
          final textAllowance = ((textScale - 1) * 64).clamp(0, 72).toDouble();
          final crossAxisCount = constraints.crossAxisExtent >= 680 ? 2 : 1;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 132 + textAllowance,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _GoalTile(
                goal: goals[index],
                onTap: widget.controller.isSaving
                    ? null
                    : () => widget.onEdit(goals[index]),
                onComplete:
                    goals[index].isComplete || widget.controller.isSaving
                        ? null
                        : () => _markComplete(context, goals[index]),
              ),
              childCount: goals.length,
            ),
          );
        },
      ),
    );
  }

  Future<void> _markComplete(BuildContext context, Goal goal) async {
    final success = await widget.controller.markComplete(goal);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
            content:
                Text(success ? 'Summit reached' : 'Progress was not saved')),
      );
  }

  void _showAddHint(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
          content: Text('Tap the + button to add your first goal.')));
  }
}

class _TrailOverview extends StatelessWidget {
  const _TrailOverview({required this.controller});

  final GoalController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = controller.activeGoals.length;
    final completed = controller.completedGoals.length;
    return Semantics(
      label: 'Overall goal progress ${controller.averageProgress} percent',
      child: Container(
        constraints: const BoxConstraints(minHeight: 188),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _TrailMapPainter(
                  lineColor: scheme.primary.withValues(alpha: 0.15),
                  routeColor: scheme.secondary,
                  progress: controller.averageProgress / 100,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.landscape_outlined,
                              color: scheme.onPrimaryContainer),
                          const SizedBox(width: 10),
                          Text(
                            'Your trail',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: scheme.onPrimaryContainer),
                          ),
                        ],
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_off_outlined, size: 16),
                              SizedBox(width: 6),
                              Text('Offline'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    controller.goals.isEmpty
                        ? 'Choose a summit.\nTake one clear step.'
                        : controller.averageProgress == 100
                            ? 'Every current goal\nhas reached its summit.'
                            : '${controller.averageProgress}% of the way\nacross your goals.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$active active  •  $completed completed',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailMapPainter extends CustomPainter {
  _TrailMapPainter(
      {required this.lineColor,
      required this.routeColor,
      required this.progress});

  final Color lineColor;
  final Color routeColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final contourPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var index = 0; index < 5; index++) {
      final inset = 18.0 + index * 19;
      final path = Path()
        ..moveTo(size.width * 0.46, -10 + inset)
        ..cubicTo(
          size.width * 0.72,
          10 + inset,
          size.width * 0.78,
          size.height * 0.42 + inset / 2,
          size.width + 20,
          size.height * 0.36 + inset,
        );
      canvas.drawPath(path, contourPaint);
    }

    final route = Path()
      ..moveTo(size.width * 0.52, size.height * 0.94)
      ..cubicTo(
        size.width * 0.61,
        size.height * 0.72,
        size.width * 0.88,
        size.height * 0.80,
        size.width * 0.74,
        size.height * 0.46,
      )
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.28,
        size.width * 0.92,
        size.height * 0.20,
        size.width * 0.88,
        -8,
      );
    final metric = route.computeMetrics().first;
    canvas.drawPath(
      route,
      Paint()
        ..color = routeColor.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    if (progress > 0) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress.clamp(0, 1)),
        Paint()
          ..color = routeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrailMapPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.routeColor != routeColor;
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onSelected});

  final GoalCategory? selected;
  final ValueChanged<GoalCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...GoalCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category.label),
                selected: selected == category,
                onSelected: (_) => onSelected(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile(
      {required this.goal, required this.onTap, required this.onComplete});

  final Goal goal;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: goal.isComplete
                    ? '${goal.title}, complete'
                    : 'Mark ${goal.title} complete',
                child: IconButton.filledTonal(
                  onPressed: onComplete,
                  tooltip: goal.isComplete ? 'Completed' : 'Mark complete',
                  icon:
                      Icon(goal.isComplete ? Icons.flag : Icons.outlined_flag),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.title,
                            maxLines: textScale > 1.2 ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  decoration: goal.isComplete
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${goal.progress}%',
                            style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: goal.progress / 100,
                        minHeight: 7,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color:
                            goal.isComplete ? scheme.primary : scheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(_categoryIcon(goal.category),
                            size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 5),
                        Text(goal.category.label,
                            style: Theme.of(context).textTheme.bodySmall),
                        if (goal.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.event_outlined,
                              size: 16, color: scheme.onSurfaceVariant),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(_formatDate(goal.dueDate!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _categoryIcon(GoalCategory category) => switch (category) {
        GoalCategory.personal => Icons.person_outline,
        GoalCategory.health => Icons.favorite_outline,
        GoalCategory.learning => Icons.school_outlined,
        GoalCategory.work => Icons.work_outline,
      };

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signpost_outlined,
              size: 68, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          Text('No goals yet',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            'Pick one meaningful destination. You can add the next step and track progress entirely on this device.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('How to add a goal'),
          ),
        ],
      ),
    );
  }
}

class _LoadingTrail extends StatelessWidget {
  const _LoadingTrail();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 80),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(width: 190, height: 42, color: color),
        ),
        const SizedBox(height: 28),
        Container(
            height: 188,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(28))),
        const SizedBox(height: 30),
        for (var index = 0; index < 3; index++) ...[
          Container(
              height: 132,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.controller});

  final GoalController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Goals unavailable',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(controller.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
