import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../models/entry.dart';
import '../widgets/item_tile.dart';
import '../widgets/total_header.dart';
import '../widgets/new_item_modal.dart';
import '../widgets/editable_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Entry> _breadcrumbs = [];
  String? _currentParentId;
  String _screenTitle = 'Balance Sheet';

  void _showNewItemModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NewItemModal(parentId: _currentParentId),
    );
  }

  void _navigateToSubItems(Entry item) {
    setState(() {
      _breadcrumbs.add(item);
      _currentParentId = item.id;
    });
  }

  void _navigateToBreadcrumb(int index) {
    setState(() {
      if (index == -1) {
        // Navigate to root
        _breadcrumbs.clear();
        _currentParentId = null;
      } else {
        // Navigate to specific breadcrumb
        _breadcrumbs.removeRange(index + 1, _breadcrumbs.length);
        _currentParentId = _breadcrumbs.isEmpty ? null : _breadcrumbs.last.id;
      }
    });
  }

  Widget _buildBreadcrumbs() {
    if (_breadcrumbs.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            InkWell(
              onTap: () => _navigateToBreadcrumb(-1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (int i = 0; i < _breadcrumbs.length; i++) ...[
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
              InkWell(
                onTap: i < _breadcrumbs.length - 1
                    ? () => _navigateToBreadcrumb(i)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    _breadcrumbs[i].description,
                    style: TextStyle(
                      color: i < _breadcrumbs.length - 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: i < _breadcrumbs.length - 1
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }

  void _editTitle() async {
    final newTitle = await showEditTitleDialog(
      context,
      currentTitle: _screenTitle,
      dialogTitle: 'Edit Screen Title',
    );
    
    if (newTitle != null && newTitle != _screenTitle) {
      setState(() {
        _screenTitle = newTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(_screenTitle),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: _editTitle,
              tooltip: 'Edit title',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const TotalHeader(),
          _buildBreadcrumbs(),
          Expanded(
            child: Consumer<ItemProvider>(
              builder: (context, provider, child) {
                final items = _currentParentId == null
                    ? provider.items
                    : provider.getChildrenForItem(_currentParentId!);
                    
                return ListView.builder(
                  itemCount: items.isEmpty ? 1 : items.length,
                  itemBuilder: (context, index) {
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _currentParentId == null
                                ? 'No items yet. Add one using the + button!'
                                : 'No sub-items yet. Add one using the + button!',
                          ),
                        ),
                      );
                    }
                    final item = items[index];
                    return ItemTile(
                      item: item,
                      onTap: () {}, // ExpansionTile handles the tap now
                      onDelete: () => provider.deleteItem(item.id, context),
                      onEdit: (updatedItem) =>
                          provider.updateItem(item.id, updatedItem, context),
                      onLongPress: () => _navigateToSubItems(item),
                      onDoubleTap: () => _navigateToSubItems(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewItemModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
