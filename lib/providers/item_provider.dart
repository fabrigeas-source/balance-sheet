import 'package:flutter/foundation.dart';
import '../models/entry.dart';

class ItemProvider extends ChangeNotifier {
  final List<Entry> _items = [];

  List<Entry> get items => List.unmodifiable(_items);

  double get total => _items.fold(0, (sum, item) {
        return sum +
            (item.type == EntryType.revenue ? item.amount : -item.amount);
      });

  void addItem(Entry item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(String id, Entry updatedItem) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Entry? getItem(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
