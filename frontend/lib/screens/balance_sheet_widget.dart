import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../models/entry.dart';
import '../widgets/item_tile.dart';
import '../widgets/total_header.dart';
import '../widgets/quick_add_bar.dart';
import '../widgets/quick_add_config.dart';
import '../theme/app_theme.dart';
import 'base_page.dart';

class BalanceSheetWidget extends BasePage {
  const BalanceSheetWidget({Key? key}) : super(key: key);

  @override
  State<BalanceSheetWidget> createState() => _BalanceSheetWidgetState();
}

class _BalanceSheetWidgetState extends BasePageState<BalanceSheetWidget> {
  final Set<String> _selectedItems = {};

  // Quick add controllers for balance sheet
  final TextEditingController _quickAddController = TextEditingController();
  final TextEditingController _quickAmountController = TextEditingController();
  final TextEditingController _quickDetailsController = TextEditingController();
  final FocusNode _quickAddFocusNode = FocusNode();
  bool _quickExpanded = false;

  @override
  void initState() {
    super.initState();
    _quickAddController.addListener(() => setState(() {}));
    _quickAmountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _quickAddController.dispose();
    _quickAmountController.dispose();
    _quickDetailsController.dispose();
    _quickAddFocusNode.dispose();
    super.dispose();
  }

  void _toggleQuickExpanded() {
    setState(() => _quickExpanded = !_quickExpanded);
    if (_quickExpanded) FocusScope.of(context).requestFocus(_quickAddFocusNode);
  }

  void _handleQuickAddItem() {
    final text = _quickAddController.text.trim();
    if (text.isEmpty) return;
    final amount = double.tryParse(_quickAmountController.text) ?? 0.0;
    final details = _quickDetailsController.text.trim().isEmpty
        ? null
        : _quickDetailsController.text.trim();

    final entry = Entry(
      id: DateTime.now().toIso8601String(),
      description: text,
      amount: amount,
      type: EntryType.expense,
      parentId: currentParentId,
      details: details,
    );

    context.read<ItemProvider>().addItem(entry, context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added'), backgroundColor: Colors.green),
    );
    _quickAddController.clear();
    _quickAmountController.clear();
    _quickDetailsController.clear();
    setState(() => _quickExpanded = false);
  }

  bool get _isQuickAddValid {
    final textValid = _quickAddController.text.trim().isNotEmpty;
    final amountText = _quickAmountController.text.trim();
    final amountValid = amountText.isEmpty || double.tryParse(amountText) != null;
    return textValid && amountValid;
  }

  @override
  void onSelectionModeExited() {
    _selectedItems.clear();
  }

  // Exposed API for parent HomeScreen
  @override
  QuickAddConfig getQuickAddConfig() => QuickAddConfig(
        controller: _quickAddController,
        focusNode: _quickAddFocusNode,
        expanded: _quickExpanded,
        toggleExpanded: _toggleQuickExpanded,
        onSend: _handleQuickAddItem,
        expandedContent: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _quickAmountController,
              decoration: const InputDecoration(
                hintText: 'Amount',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
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
          ],
        ),
        sendEnabled: _isQuickAddValid,
        hintText: 'Quick add item...',
      );

  @override
  String get screenTitle => 'Balance Sheet';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TotalHeader(),
        buildBreadcrumbs(context),
        Expanded(
          child: Consumer<ItemProvider>(
            builder: (context, provider, child) {
              final items = currentParentId == null
                  ? provider.items
                  : provider.getChildrenForItem(currentParentId!);

              return ListView.builder(
                itemCount: items.isEmpty ? 1 : items.length,
                itemBuilder: (context, index) {
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingLarge),
                        child: Text(
                          currentParentId == null
                              ? 'No items yet. Add one using the + button!'
                              : 'No sub-items yet. Add one using the + button!',
                        ),
                      ),
                    );
                  }
                  final item = items[index];
                  return ItemTile(
                    item: item,
                    onTap: () {},
                    onDelete: () {
                      final deleted = provider.deleteItem(item.id, context);
                      if (deleted != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${deleted.description} deleted'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () => provider.addItem(deleted, context),
                            ),
                          ),
                        );
                      }
                    },
                    onEdit: (updatedItem) =>
                        provider.updateItem(item.id, updatedItem, context),
                    onLongPress: () => navigateToSub(item),
                    onDoubleTap: () => navigateToSub(item),
                    showCheckbox: isSelectionMode,
                    isSelected: _selectedItems.contains(item.id),
                    onSelectionChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedItems.add(item.id);
                        } else {
                          _selectedItems.remove(item.id);
                        }
                      });
                    },
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
