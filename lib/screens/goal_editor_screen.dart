import 'package:flutter/material.dart';

import '../models/goal.dart';

class GoalEditorResult {
  const GoalEditorResult.saved(this.goal) : deletedId = null;
  const GoalEditorResult.deleted(this.deletedId) : goal = null;

  final Goal? goal;
  final String? deletedId;
}

class GoalEditorScreen extends StatefulWidget {
  const GoalEditorScreen({super.key, this.goal});

  final Goal? goal;

  @override
  State<GoalEditorScreen> createState() => _GoalEditorScreenState();
}

class _GoalEditorScreenState extends State<GoalEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late GoalCategory _category;
  late double _progress;
  DateTime? _dueDate;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _noteController = TextEditingController(text: goal?.note ?? '');
    _category = goal?.category ?? GoalCategory.personal;
    _progress = (goal?.progress ?? 0).toDouble();
    _dueDate = goal?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit goal' : 'New goal'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              28 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            children: [
              Text(
                _isEditing
                    ? 'Adjust the route without losing sight of the summit.'
                    : 'Name one destination you want to move toward.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                autofocus: !_isEditing,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Goal title',
                  hintText: 'Complete my first 5K',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a clear goal title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Text('Area', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GoalCategory.values
                    .map(
                      (category) => ChoiceChip(
                        label: Text(category.label),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Next step or note',
                  hintText: 'What would make progress visible?',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _DueDateField(
                dueDate: _dueDate,
                onChoose: _pickDueDate,
                onClear: _dueDate == null
                    ? null
                    : () => setState(() => _dueDate = null),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                      child: Text('Progress',
                          style: Theme.of(context).textTheme.titleMedium)),
                  Text('${_progress.round()}%',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              Semantics(
                label: 'Goal progress ${_progress.round()} percent',
                child: Slider(
                  value: _progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_progress.round()}%',
                  onChanged: (value) => setState(() => _progress = value),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: Text(_isEditing ? 'Save changes' : 'Create goal'),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 56),
                Divider(color: Theme.of(context).colorScheme.outlineVariant),
                const SizedBox(height: 24),
                Text('Remove from this device',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Deleting a goal cannot be undone.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete goal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 10, now.month, now.day);
    final savedDate = _dueDate;
    final initialDate = savedDate != null &&
            !savedDate.isBefore(today) &&
            !savedDate.isAfter(lastDate)
        ? savedDate
        : today.add(const Duration(days: 30));
    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: lastDate,
      helpText: 'Choose a target date',
    );
    if (result != null) setState(() => _dueDate = result);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final original = widget.goal;
    final goal = Goal(
      id: original?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      category: _category,
      progress: _progress.round(),
      createdAt: original?.createdAt ?? DateTime.now(),
      dueDate: _dueDate,
    );
    Navigator.of(context).pop(GoalEditorResult.saved(goal));
  }

  Future<void> _confirmDelete() async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Delete this goal?'),
        content: Text(
            '“${widget.goal!.title}” and its progress will be removed from this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep goal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (delete == true && mounted) {
      Navigator.of(context).pop(GoalEditorResult.deleted(widget.goal!.id));
    }
  }
}

class _DueDateField extends StatelessWidget {
  const _DueDateField(
      {required this.dueDate, required this.onChoose, required this.onClear});

  final DateTime? dueDate;
  final VoidCallback onChoose;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final label = dueDate == null
        ? 'No target date'
        : '${dueDate!.day.toString().padLeft(2, '0')}/'
            '${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.year}';
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onChoose,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.event_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target date',
                        style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 2),
                    Text(label, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  onPressed: onClear,
                  tooltip: 'Clear target date',
                  icon: const Icon(Icons.close),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
