import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/entry.dart';

class ItemProvider extends ChangeNotifier {
  final List<Entry> _items = [
    Entry(
      id: 'mock-1',
      description: 'Monthly Rent',
      amount: 1200.00,
      type: EntryType.expense,
      details: 'Apartment rent for October',
    ),
    Entry(
      id: 'mock-2',
      description: 'Utility Bills',
      amount: 150.50,
      type: EntryType.expense,
      details: 'Electricity and water bills',
    ),
    Entry(
      id: 'mock-3',
      description: 'Groceries',
      amount: 85.75,
      type: EntryType.expense,
      details: 'Weekly grocery shopping',
    ),
  ];

  List<Entry> get items => List.unmodifiable(_items);

  double get total => _items.fold(0, (sum, item) {
        return sum +
            (item.type == EntryType.revenue ? item.amount : -item.amount);
      });

  void addItem(Entry item, BuildContext context) {
    _items.add(item);
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.type == EntryType.revenue ? 'Revenue' : 'Expense'} added successfully'),
        backgroundColor: item.type == EntryType.revenue ? Colors.green : Colors.red,
      ),
    );
  }

  void updateItem(String id, Entry updatedItem, BuildContext context) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item updated successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void deleteItem(String id, BuildContext context) {
    final deletedItem = _items.firstWhere((item) => item.id == id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item deleted'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  Entry? getItem(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
