import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/entry.dart';

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
  bool _isExpanded = false;
  bool _isEditing = false;
  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  late TextEditingController _amountController;

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

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset values when cancelling edit
        _descriptionController.text = widget.item.description;
        _detailsController.text = widget.item.details ?? '';
        _amountController.text = widget.item.amount.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(widget.item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('DELETE'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.2),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              title: _isEditing
                ? TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                : Text(
                    widget.item.description,
                    style: theme.textTheme.titleMedium,
                  ),
              subtitle: _isEditing
                ? TextField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintText: 'Details (optional)',
                    ),
                  )
                : widget.item.details != null 
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.item.details!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ) 
                    : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditing)
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                          prefixText: '\$',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                    )
                  else
                    Text(
                      '${widget.item.type == EntryType.expense ? "-" : "+"}\$${widget.item.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: widget.item.type == EntryType.expense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_isExpanded && !_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _toggleEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded = expanded;
                  if (!expanded && _isEditing) {
                    _isEditing = false;
                    final updatedItem = widget.item.copyWith(
                      description: _descriptionController.text,
                      details: _detailsController.text.isEmpty ? null : _detailsController.text,
                      amount: double.tryParse(_amountController.text) ?? widget.item.amount,
                    );
                    widget.onEdit?.call(updatedItem);
                  }
                });
              },
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isEditing) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final updatedItem = widget.item.copyWith(
                                    description: _descriptionController.text,
                                    details: _detailsController.text.isEmpty ? null : _detailsController.text,
                                    amount: double.tryParse(_amountController.text) ?? widget.item.amount,
                                    type: EntryType.expense,
                                  );
                                  widget.onEdit?.call(updatedItem);
                                  setState(() {
                                    _isEditing = false;
                                    _isExpanded = false;
                                  });
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  foregroundColor: Colors.red,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                onPressed: () {
                                  final updatedItem = widget.item.copyWith(
                                    description: _descriptionController.text,
                                    details: _detailsController.text.isEmpty ? null : _detailsController.text,
                                    amount: double.tryParse(_amountController.text) ?? widget.item.amount,
                                    type: EntryType.revenue,
                                  );
                                  widget.onEdit?.call(updatedItem);
                                  setState(() {
                                    _isEditing = false;
                                    _isExpanded = false;
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                  foregroundColor: Colors.green,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              IconButton(
                                onPressed: () {
                                  _descriptionController.text = widget.item.description;
                                  _detailsController.text = widget.item.details ?? '';
                                  _amountController.text = widget.item.amount.toString();
                                  setState(() => _isEditing = false);
                                },
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Divider(),
                        ),
                      ],
                      if (widget.item.details?.isNotEmpty ?? false) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Details',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.details!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          Text(
                            widget.item.createdAt.toLocal().toString().split('.')[0],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
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
