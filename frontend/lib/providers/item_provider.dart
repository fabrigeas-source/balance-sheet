import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/entry.dart';

class ItemProvider extends ChangeNotifier {
  List<Entry> _items = [];
  bool _isLoaded = false;

  ItemProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (_isLoaded) return;
    
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString('items');
    
    if (itemsJson != null) {
      final List<dynamic> decoded = json.decode(itemsJson);
      _items = decoded.map((item) => Entry.fromJson(item)).toList();
    } else {
      // Load default mock data only if no saved data exists
      _items = [
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
      await _saveItems();
    }
    
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('items', itemsJson);
  }

  List<Entry> get items => List.unmodifiable(_items.where((item) => item.parentId == null));
  
  List<Entry> getChildrenForItem(String parentId) {
    return _items.where((item) => item.parentId == parentId).toList();
  }
  
  double getSubItemsTotal(String parentId) {
    final children = getChildrenForItem(parentId);
    return children.fold(0.0, (sum, item) {
      return sum + (item.type == EntryType.revenue ? item.amount : -item.amount);
    });
  }

  void createSubList(String parentId, Entry newItem) {
    final subItem = newItem.copyWith(
      parentId: parentId,
      id: DateTime.now().toIso8601String(),
    );
    _items.add(subItem);
    _saveItems();
    notifyListeners();
  }

  double get total => _items.fold(0, (sum, item) {
        return sum +
            (item.type == EntryType.revenue ? item.amount : -item.amount);
      });

  void addItem(Entry item, [BuildContext? context]) {
    _items.add(item);
    _saveItems();
    notifyListeners();
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.type == EntryType.revenue ? 'Revenue' : 'Expense'} added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void updateItem(String id, Entry updatedItem, BuildContext context) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = updatedItem;
      _saveItems();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item updated successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  /// Deletes an item and returns the deleted [Entry] so callers can offer an
  /// undo action. If the item isn't found returns null.
  Entry? deleteItem(String id, BuildContext? context) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    final deletedItem = _items.removeAt(index);
    _saveItems();
    notifyListeners();
    // Caller may show a SnackBar with an Undo action.
    return deletedItem;
  }

  Entry? getItem(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
