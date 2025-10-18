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
    
    widget.onEdit?.call(updatedEntry);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(widget.item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
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
        ),
        onDismissed: (_) => widget.onDelete(),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _isEditing
                          ? TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                            )
                          : Text(
                              widget.item.description,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                    ),
                    const SizedBox(width: 16),
                    _isEditing
                        ? TextFormField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              prefixText: '\$',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                          )
                        : Text(
                            '\$${widget.item.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: widget.item.amount >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                          ),
                  ],
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isEditing) ...[
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
                    ] else if (widget.onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
