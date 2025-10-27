import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<Task>? onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const TaskTile({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
    this.onToggle,
    this.onLongPress,
    this.onDoubleTap,
  }) : super(key: key);

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  DateTime? _selectedDueDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.task.description);
    _detailsController = TextEditingController(text: widget.task.details ?? '');
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _handleEdit() async {
    if (!_isEditing) return;
    
    final updatedTask = widget.task.copyWith(
      description: _descriptionController.text,
      details: _detailsController.text,
      dueDate: _selectedDueDate,
    );
    
    context.read<TaskProvider>().updateTask(widget.task.id, updatedTask, context);
    setState(() => _isEditing = false);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _createSubList(BuildContext context) {
    // Create initial sub-task
    final subTask = Task(
      id: '${widget.task.id}-sub-${DateTime.now().millisecondsSinceEpoch}',
      description: 'Sub-task',
      parentId: widget.task.id,
    );
    context.read<TaskProvider>().createSubList(widget.task.id, subTask);
    
    // Navigate to sub-list immediately
    if (widget.onDoubleTap != null) {
      widget.onDoubleTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final children = provider.getChildrenForTask(widget.task.id);
    final hasChildren = children.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(widget.task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => context.read<TaskProvider>().deleteTask(widget.task.id, context),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child: GestureDetector(
          onLongPress: widget.onLongPress,
          onDoubleTap: widget.onDoubleTap,
          child: Card(
            child: ExpansionTile(
              leading: Checkbox(
                value: widget.task.isCompleted,
                onChanged: (_) => widget.onToggle?.call(),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.task.description,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: widget.task.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                        ),
                        if (hasChildren)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: InkWell(
                              onTap: widget.onDoubleTap,
                              child: Icon(
                                Icons.folder,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.task.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          '${widget.task.dueDate!.month}/${widget.task.dueDate!.day}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: widget.task.dueDate!.isBefore(DateTime.now())
                            ? Colors.red.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                      ),
                    ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.task.details?.isNotEmpty == true || _isEditing) ...[
                        const SizedBox(height: 8),
                        _isEditing
                            ? TextFormField(
                                controller: _detailsController,
                                decoration: const InputDecoration(
                                  labelText: 'Details',
                                ),
                                maxLines: null,
                              )
                            : Text(
                                widget.task.details ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                      ],
                      if (_isEditing) ...[
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(
                            _selectedDueDate == null
                                ? 'No due date'
                                : 'Due: ${_selectedDueDate!.month}/${_selectedDueDate!.day}/${_selectedDueDate!.year}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: _pickDueDate,
                        ),
                        if (_selectedDueDate != null)
                          TextButton(
                            onPressed: () => setState(() => _selectedDueDate = null),
                            child: const Text('Clear due date'),
                          ),
                      ],
                      if (children.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Sub-tasks: ${children.length}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                      if (_isEditing) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _descriptionController.text = widget.task.description;
                                  _detailsController.text = widget.task.details ?? '';
                                  _selectedDueDate = widget.task.dueDate;
                                });
                              },
                              child: const Text('CANCEL'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _handleEdit,
                              child: const Text('SAVE'),
                            ),
                          ],
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!hasChildren)
                              IconButton(
                                icon: const Icon(Icons.playlist_add),
                                tooltip: 'Create Sub-task',
                                onPressed: () => _createSubList(context),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              onPressed: () => setState(() => _isEditing = true),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
