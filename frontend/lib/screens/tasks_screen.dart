import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../widgets/quick_add_bar.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Task> _breadcrumbs = [];
  String? _currentParentId;
  String _screenTitle = 'Tasks';
  bool _isSelectionMode = false;
  final Set<String> _selectedTasks = {};
  final TextEditingController _quickAddController = TextEditingController();
  final TextEditingController _quickDetailsController = TextEditingController();
  DateTime? _quickDueDate;
  final FocusNode _quickAddFocusNode = FocusNode();
  bool _quickExpanded = false;

  @override
  void initState() {
    super.initState();
    _quickAddController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quickAddController.dispose();
    _quickDetailsController.dispose();
    _quickAddFocusNode.dispose();
    super.dispose();
  }

  // Removed: FAB-triggered modal flow. Quick-add is persistent in the bottom bar.

  void _handleQuickAddTask() {
    final text = _quickAddController.text.trim();
    if (text.isEmpty) return;

    final details = _quickDetailsController.text.trim().isEmpty
        ? null
        : _quickDetailsController.text.trim();

    final task = Task(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      description: text,
      details: details,
      dueDate: _quickDueDate,
      parentId: _currentParentId,
    );

    context.read<TaskProvider>().addTask(task, context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added'), backgroundColor: Colors.green),
    );
    _quickAddController.clear();
    _quickDetailsController.clear();
    _quickDueDate = null;
    setState(() => _quickExpanded = false);
  }

  bool get _isQuickAddValid => _quickAddController.text.trim().isNotEmpty;

  void _toggleQuickExpanded() {
    setState(() => _quickExpanded = !_quickExpanded);
    if (_quickExpanded) FocusScope.of(context).requestFocus(_quickAddFocusNode);
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _quickDueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _quickDueDate = picked);
    }
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
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing, vertical: AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingSmall),
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
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall, vertical: AppTheme.spacingSmall),
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
        title: Row(
          children: [
            Expanded(
              child: Text(_screenTitle),
            ),
            IconButton(
              icon: Icon(_isSelectionMode ? Icons.check : Icons.select_all, size: 20),
              onPressed: () {
                setState(() {
                  _isSelectionMode = !_isSelectionMode;
                  if (!_isSelectionMode) {
                    _selectedTasks.clear();
                  }
                });
              },
              tooltip: _isSelectionMode ? 'Exit selection' : 'Select items',
            ),
          ],
        ),
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
                      showCheckbox: _isSelectionMode,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: QuickAddBar(
        controller: _quickAddController,
        focusNode: _quickAddFocusNode,
        expanded: _quickExpanded,
        toggleExpanded: _toggleQuickExpanded,
        onSend: _handleQuickAddTask,
        hintText: 'Quick add task...',
        sendEnabled: _isQuickAddValid,
        expandedContent: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _quickDetailsController,
              decoration: const InputDecoration(
                hintText: 'Details (optional)',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: _pickDueDate,
                child: Text(_quickDueDate == null
                    ? 'Set due date'
                    : '${_quickDueDate!.day}/${_quickDueDate!.month}/${_quickDueDate!.year}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
