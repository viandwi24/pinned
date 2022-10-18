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

  static isEmpty() {
    return _items.isEmpty;
  }
}
