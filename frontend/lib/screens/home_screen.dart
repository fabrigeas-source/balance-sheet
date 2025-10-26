import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../widgets/item_tile.dart';
import '../widgets/total_header.dart';
import '../widgets/new_item_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showNewItemModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NewItemModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Sheet'),
      ),
      body: Column(
        children: [
          const TotalHeader(),
          Expanded(
            child: Consumer<ItemProvider>(
              builder: (context, provider, child) {
                final items = provider.items;
                return ListView.builder(
                  itemCount: items.isEmpty ? 1 : items.length,
                  itemBuilder: (context, index) {
                    if (items.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child:
                              Text('No items yet. Add one using the + button!'),
                        ),
                      );
                    }
                    final item = items[index];
                    return ItemTile(
                      item: item,
                      onTap: () {}, // ExpansionTile handles the tap now
                      onDelete: () => provider.deleteItem(item.id),
                      onEdit: (updatedItem) =>
                          provider.updateItem(item.id, updatedItem),
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
