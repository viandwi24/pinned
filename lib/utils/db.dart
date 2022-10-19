import 'package:eventify/eventify.dart';
import 'package:pinned/models/pinned_item.dart';

class DB {
  static EventEmitter emitter = EventEmitter();
  static final List<PinnedItem> _items = [];

  static List<PinnedItem> getAll() {
    return _items;
  }

  static add(PinnedItem item) {
    _items.add(item);
    emitter.emit('add', item);
    emitter.emit('updated', getAll());
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
    emitter.emit('updated', getAll());
  }

  static isEmpty() {
    return _items.isEmpty;
  }

  static update(String id, PinnedItem item) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index == -1) return;
    _items[index] = item;
    emitter.emit('update', item);
    emitter.emit('updated', getAll());
  }
}
