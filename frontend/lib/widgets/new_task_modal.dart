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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Task',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedDueDate == null
                      ? 'No due date'
                      : 'Due: \${_selectedDueDate!.month}/\${_selectedDueDate!.day}/\${_selectedDueDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDueDate,
                contentPadding: EdgeInsets.zero,
              ),
              if (_selectedDueDate != null)
                TextButton(
                  onPressed: () => setState(() => _selectedDueDate = null),
                  child: const Text('Clear due date'),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _handleSubmit,
                    child: const Text('Add Task'),
                  ),
                ],
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
