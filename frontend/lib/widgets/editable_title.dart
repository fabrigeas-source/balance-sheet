import 'package:flutter/material.dart';

class EditTitleDialog extends StatefulWidget {
  final String currentTitle;
  final String dialogTitle;

  const EditTitleDialog({
    Key? key,
    required this.currentTitle,
    required this.dialogTitle,
  }) : super(key: key);

  @override
  State<EditTitleDialog> createState() => _EditTitleDialogState();
}

class _EditTitleDialogState extends State<EditTitleDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 300,
          child: TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title cannot be empty';
              }
              if (value.trim().length > 50) {
                return 'Title must be 50 characters or less';
              }
              return null;
            },
            autofocus: true,
            maxLength: 50,
            onFieldSubmitted: (_) => _handleSave(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Helper function to show the edit title dialog
Future<String?> showEditTitleDialog(
  BuildContext context, {
  required String currentTitle,
  required String dialogTitle,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => EditTitleDialog(
      currentTitle: currentTitle,
      dialogTitle: dialogTitle,
    ),
  );
}