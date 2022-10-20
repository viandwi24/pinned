import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:pinned/models/pinned_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DB {
  static EventEmitter emitter = EventEmitter();
  static final List<PinnedItem> _items = [];

  static List<PinnedItem> getAll() {
    return [..._items];
  }

  static List<PinnedItem> getItemsByCategory(String category) {
    return DB.getAll().where((item) => item.category == category).toList();
  }

  static List<String> getCategories() {
    var items = _items.map((item) => item.category).toSet().toList();
    for (var i = 0; i < items.length; i++) {
      if (items[i] == '') {
        items[i] = 'all';
      }
    }
    return items;
  }

  static add(PinnedItem item) {
    _items.add(item);
    emitter.emit('add', item);
    _onUpdate();
  }

  static remove(String id) async {
    final items = _items.where((element) => element.id == id);
    // check if item exists
    if (items.isEmpty) {
      return;
    }
    final item = items.first;
    _items.remove(item);
    emitter.emit('remove', item);
    _onUpdate();
  }

  static isEmpty() {
    return _items.isEmpty;
  }

  static update(String id, PinnedItem item) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index == -1) return;
    _items[index] = item;
    emitter.emit('update', item);
    _onUpdate();
  }

  static _onUpdate() {
    emitter.emit('updated', getAll());
    dbSave();
  }

  static Future<bool> dbRead() async {
    await Future.delayed(Duration(milliseconds: 2000));
    print('DB: Reading from DB');
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getString('items');
    if (items == null) return true;
    final itemsJson = jsonDecode(items);
    if (itemsJson is List) {
      _items.clear();
      for (var item in itemsJson) {
        print('${item['title']} - ${item['type']}');
        _items.add(PinnedItem.fromJson(item));
      }
    }
    return true;
  }

  static Future<bool> dbSave() async {
    print('DB: Saving to DB');
    final prefs = await SharedPreferences.getInstance();
    final items = jsonEncode(_items.map((e) => e.toJson()).toList());
    prefs.setString('items', items);
    return true;
  }
}
