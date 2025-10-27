import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../providers/item_provider.dart';
import 'new_item_modal.dart';

class ItemTile extends StatefulWidget {
  final Entry item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<Entry>? onEdit;

  const ItemTile({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  State<ItemTile> createState() => _ItemTileState();
}

class _ItemTileState extends State<ItemTile> {
  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  late TextEditingController _amountController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.item.description);
    _detailsController = TextEditingController(text: widget.item.details ?? '');
    _amountController = TextEditingController(text: widget.item.amount.toString());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _detailsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleEdit() async {
    if (!_isEditing) return;
    
    final updatedEntry = widget.item.copyWith(
      description: _descriptionController.text,
      details: _detailsController.text,
      amount: double.tryParse(_amountController.text) ?? widget.item.amount,
    );
    
    context.read<ItemProvider>().updateItem(widget.item.id, updatedEntry, context);
    setState(() => _isEditing = false);
  }

  void _showCreateSubListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Sub-list'),
        content: const Text('Do you want to create a sub-list for this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              showDialog(
                context: context,
                builder: (ctx) => NewItemModal(parentId: widget.item.id),
              );
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = context.watch<ItemProvider>().getChildrenForItem(widget.item.id);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(widget.item.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _showCreateSubListDialog(context);
            return false;
          }
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Item'),
              content: Text('Are you sure you want to delete "${widget.item.description}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (_) => context.read<ItemProvider>().deleteItem(widget.item.id, context),
        secondaryBackground: Container(
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
        background: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Row(
            children: [
              Icon(Icons.playlist_add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Create Sub-list',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child: Card(
          child: ExpansionTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '\$${widget.item.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: widget.item.type == EntryType.revenue
                            ? Colors.green
                            : Colors.red,
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
                    if (widget.item.details?.isNotEmpty == true || _isEditing) ...[
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
                              widget.item.details ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                    ],
                    if (children.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Sub-items:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...children.map((child) => ListTile(
                        title: Text(child.description),
                        trailing: Text(
                          '\$${child.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: child.type == EntryType.revenue
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      )).toList(),
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
                                _descriptionController.text = widget.item.description;
                                _detailsController.text = widget.item.details ?? '';
                                _amountController.text = widget.item.amount.toString();
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
                          IconButton(
                            icon: const Icon(Icons.edit),
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
    );
  }
}
