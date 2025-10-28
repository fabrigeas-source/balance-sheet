import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class NewTaskBottomSheet extends StatefulWidget {
  final String? parentId;

  const NewTaskBottomSheet({Key? key, this.parentId}) : super(key: key);

  @override
  State<NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}

class _NewTaskBottomSheetState extends State<NewTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _detailsController = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _descriptionController.dispose();
    _detailsController.dispose();
    super.dispose();
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        description: _descriptionController.text,
        details: _detailsController.text.isEmpty ? null : _detailsController.text,
        dueDate: _selectedDueDate,
        parentId: widget.parentId,
      );

      context.read<TaskProvider>().addTask(task, context);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Task',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  autofocus: true,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Enter task',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: TextFormField(
                  controller: _detailsController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Add details',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: _pickDueDate,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDueDate == null
                              ? 'Add due date'
                              : 'Due: ${_selectedDueDate!.month}/${_selectedDueDate!.day}/${_selectedDueDate!.year}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _selectedDueDate == null
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (_selectedDueDate != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _selectedDueDate = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                    ],
                  ),
                ),
              ),
              if (_selectedDueDate != null)
                TextButton(
                  onPressed: () => setState(() => _selectedDueDate = null),
                  child: const Text('Clear due date'),
                ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _handleSubmit,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the bottom sheet
Future<void> showNewTaskBottomSheet(BuildContext context, {String? parentId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NewTaskBottomSheet(parentId: parentId),
  );
}

// Keep the old modal for backward compatibility but make it use bottom sheet
class NewTaskModal extends StatelessWidget {
  final String? parentId;

  const NewTaskModal({Key? key, this.parentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Immediately show bottom sheet instead of dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(); // Close the dialog
      showNewTaskBottomSheet(context, parentId: parentId);
    });
    
    return const SizedBox.shrink();
  }
}
