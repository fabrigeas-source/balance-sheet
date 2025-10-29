import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../widgets/quick_add_bar.dart';
import '../widgets/quick_add_config.dart';
import '../theme/app_theme.dart';
import 'base_page.dart';

class TasksWidget extends BasePage {
  const TasksWidget({Key? key}) : super(key: key);

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends BasePageState<TasksWidget> {
  final Set<String> _selectedTasks = {};

  // Quick add controllers for tasks
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

  void _toggleQuickExpanded() {
    setState(() => _quickExpanded = !_quickExpanded);
    if (_quickExpanded) FocusScope.of(context).requestFocus(_quickAddFocusNode);
  }

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
      parentId: currentParentId,
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

  @override
  void onSelectionModeExited() {
    _selectedTasks.clear();
  }

  // Exposed API for parent HomeScreen
  @override
  QuickAddConfig getQuickAddConfig() => QuickAddConfig(
        controller: _quickAddController,
        focusNode: _quickAddFocusNode,
        expanded: _quickExpanded,
        toggleExpanded: _toggleQuickExpanded,
        onSend: _handleQuickAddTask,
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
        sendEnabled: _isQuickAddValid,
        hintText: 'Quick add task...',
      );

  @override
  String get screenTitle => 'Tasks';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildBreadcrumbs(context),
        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              final tasks = currentParentId == null
                  ? provider.tasks
                  : provider.getChildrenForTask(currentParentId!);

              return ListView.builder(
                itemCount: tasks.isEmpty ? 1 : tasks.length,
                itemBuilder: (context, index) {
                  if (tasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          currentParentId == null
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
                    onLongPress: () => navigateToSub(task),
                    onDoubleTap: () => navigateToSub(task),
                    showCheckbox: isSelectionMode,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

