import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../providers/item_provider.dart';

class NewItemBottomSheet extends StatefulWidget {
  final String? parentId;
  
  const NewItemBottomSheet({Key? key, this.parentId}) : super(key: key);

  @override
  State<NewItemBottomSheet> createState() => _NewItemBottomSheetState();
}

class _NewItemBottomSheetState extends State<NewItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _detailsController = TextEditingController();
  final _amountController = TextEditingController();
  bool _showDetails = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _detailsController.dispose();
    _amountController.dispose();
    super.dispose();
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
                    'New Item',
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
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!_showDetails)
                TextButton.icon(
                  onPressed: () => setState(() => _showDetails = true),
                  icon: const Icon(Icons.add),
                  label: const Text('ADD DETAILS'),
                ),
              if (_showDetails) ...[
                TextFormField(
                  controller: _detailsController,
                  decoration: InputDecoration(
                    labelText: 'Details',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _detailsController.clear();
                          _showDetails = false;
                        });
                      },
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final entry = Entry(
                            id: DateTime.now().toIso8601String(),
                            description: _descriptionController.text,
                            details: _detailsController.text.isEmpty
                                ? null
                                : _detailsController.text,
                            amount: double.parse(_amountController.text),
                            type: EntryType.expense,
                            parentId: widget.parentId,
                          );
                          if (widget.parentId != null) {
                            context.read<ItemProvider>().createSubList(widget.parentId!, entry);
                          } else {
                            context.read<ItemProvider>().addItem(entry, context);
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.remove_circle_outline),
                          SizedBox(width: 8),
                          Text('EXPENSE'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final entry = Entry(
                            id: DateTime.now().toIso8601String(),
                            description: _descriptionController.text,
                            details: _detailsController.text.isEmpty
                                ? null
                                : _detailsController.text,
                            amount: double.parse(_amountController.text),
                            type: EntryType.revenue,
                            parentId: widget.parentId,
                          );
                          if (widget.parentId != null) {
                            context.read<ItemProvider>().createSubList(widget.parentId!, entry);
                          } else {
                            context.read<ItemProvider>().addItem(entry, context);
                          }
                          Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline),
                          SizedBox(width: 8),
                          Text('REVENUE'),
                        ],
                      ),
                    ),
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
Future<void> showNewItemBottomSheet(BuildContext context, {String? parentId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NewItemBottomSheet(parentId: parentId),
  );
}

// Keep the old modal for backward compatibility but make it use bottom sheet
class NewItemModal extends StatelessWidget {
  final String? parentId;
  
  const NewItemModal({Key? key, this.parentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Immediately show bottom sheet instead of dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop(); // Close the dialog
      showNewItemBottomSheet(context, parentId: parentId);
    });
    
    return const SizedBox.shrink();
  }
}
