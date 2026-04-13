import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskService = TaskService();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _filterTasksByName(List<Task> tasks) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return tasks;
    return tasks
        .where((t) => t.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  Future<void> _addTask() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      final scheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task name cannot be empty.',
            style: TextStyle(color: scheme.onError),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: scheme.error,
        ),
      );
      return;
    }
    await _taskService.addTask(name);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search tasks by name',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Task name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _MessagePanel(
                    icon: Icons.error_outline,
                    iconColor: colorScheme.error,
                    title: 'Could not load tasks',
                    body: snapshot.error.toString(),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _MessagePanel(
                    icon: Icons.hourglass_top,
                    iconColor: colorScheme.primary,
                    title: 'Loading tasks',
                    body: 'Please wait while tasks are fetched.',
                    centerChild: const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final allTasks = snapshot.data ?? <Task>[];
                if (allTasks.isEmpty) {
                  return _MessagePanel(
                    icon: Icons.inbox_outlined,
                    iconColor: colorScheme.outline,
                    title: 'No tasks yet',
                    body: 'Add a task name above and tap Add to create your first task.',
                  );
                }

                final filtered = _filterTasksByName(allTasks);
                if (filtered.isEmpty) {
                  return _MessagePanel(
                    icon: Icons.search_off_outlined,
                    iconColor: colorScheme.outline,
                    title: 'No matching tasks',
                    body:
                        'No task names contain "${_searchQuery.trim()}".\nTry a different search or clear the search bar.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final task = filtered[index];
                    return Dismissible(
                      key: ValueKey<String>('task-${task.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_forever,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      onDismissed: (_) {
                        _taskService.deleteTask(task.id);
                      },
                      child: _ExpandableTaskTile(
                        task: task,
                        taskService: _taskService,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.centerChild,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final Widget? centerChild;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            ...[centerChild].whereType<Widget>(),
          ],
        ),
      ),
    );
  }
}

class _ExpandableTaskTile extends StatefulWidget {
  const _ExpandableTaskTile({
    required this.task,
    required this.taskService,
  });

  final Task task;
  final TaskService taskService;

  @override
  State<_ExpandableTaskTile> createState() => _ExpandableTaskTileState();
}

class _ExpandableTaskTileState extends State<_ExpandableTaskTile> {
  final _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _addSubtask() async {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    await widget.taskService.addSubtask(widget.task.id, text);
    _subtaskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: ExpansionTile(
        leading: Checkbox(
          value: task.isComplete,
          onChanged: (value) {
            if (value == null) return;
            widget.taskService.updateTask(
              task.copyWith(isComplete: value),
            );
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.name,
                style: task.isComplete
                    ? TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: theme.hintColor,
                      )
                    : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete task',
              onPressed: () => widget.taskService.deleteTask(task.id),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (task.subtasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'No subtasks yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  )
                else
                  ...task.subtasks.map(
                    (sub) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(sub),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'Remove subtask',
                        onPressed: () => widget.taskService.removeSubtask(
                          task.id,
                          sub,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: 'Subtask',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _addSubtask,
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
