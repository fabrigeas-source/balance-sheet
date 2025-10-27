import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../widgets/new_task_modal.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _breadcrumbs = [];
  String? _currentParentId;

  void _showNewTaskModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NewTaskModal(parentId: _currentParentId),
    );
  }

  void _navigateToSubTasks(Task task) {
    setState(() {
      _breadcrumbs.add(task);
      _currentParentId = task.id;
    });
  }

  void _navigateToBreadcrumb(int index) {
    setState(() {
      if (index == -1) {
        // Navigate to root
        _breadcrumbs.clear();
        _currentParentId = null;
      } else {
        // Navigate to specific breadcrumb
        _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);
        _currentParentId = _breadcrumbs.isEmpty ? null : _breadcrumbs.last.id;
      }
    });
  }

  Widget _buildBreadcrumbs() {
    if (_breadcrumbs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _navigateToBreadcrumb(-1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.home,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (int i = 0; i < _breadcrumbs.length; i++) ...[
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                InkWell(
                  onTap: i < _breadcrumbs.length - 1
                      ? () => _navigateToBreadcrumb(i)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      _breadcrumbs[i].description,
                      style: TextStyle(
                        color: i < _breadcrumbs.length - 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: i < _breadcrumbs.length - 1
                            ? FontWeight.w500
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          _buildBreadcrumbs(),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final tasks = _currentParentId == null
                    ? provider.tasks
                    : provider.getChildrenForTask(_currentParentId!);
                    
                return ListView.builder(
                  itemCount: tasks.isEmpty ? 1 : tasks.length,
                  itemBuilder: (context, index) {
                    if (tasks.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _currentParentId == null
                                ? 'No tasks yet. Add one using the + button!'
                                : 'No sub-tasks yet. Add one using the + button!',
                          ),
                        ),
                      );
                    }
                    final task = tasks[index];
                    return TaskTile(
                      task: task,
                      onTap: () {},
                      onDelete: () => provider.deleteTask(task.id, context),
                      onEdit: (updatedTask) =>
                          provider.updateTask(task.id, updatedTask, context),
                      onToggle: () => provider.toggleTask(task.id),
                      onLongPress: () => _navigateToSubTasks(task),
                      onDoubleTap: () => _navigateToSubTasks(task),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTaskModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
