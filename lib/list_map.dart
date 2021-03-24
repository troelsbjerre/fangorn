import 'dart:collection';
import 'package:fangorn/src/util.dart';

class ListMap<K, V> extends MapBase<K, V> implements SplayTreeMap<K, V> {
  final List<K> _keys = [];
  final List<V> _values = [];
  final Comparator<K> _compare;
  final Predicate<K> _validKey;

  ListMap(
      [int Function(K key1, K key2)? compare,
      bool Function(K potentialKey)? isValidKey])
      : _compare = compare ?? defaultCompare<K>(),
        _validKey = isValidKey ?? ((_) => true);

  @override
  bool get isEmpty => _keys.isEmpty;

  @override
  bool get isNotEmpty => _keys.isNotEmpty;

  @override
  int get length => _keys.length;

  @override
  V? operator [](Object? key) {
    if (key is! K || !_validKey(key)) return null;
    var i = bisectLeft(_keys, key, _compare);
    return i < _keys.length && _compare(_keys[i], key) == 0 ? _values[i] : null;
  }

  @override
  void operator []=(K key, V value) {
    var i = bisectLeft(_keys, key, _compare);
    if (i < _keys.length && _compare(_keys[i], key) == 0) {
      _values[i] = value;
    } else {
      _keys.insert(i, key);
      _values.insert(i, value);
    }
  }

  @override
  void clear() {
    _keys.clear();
    _values.clear();
  }

  @override
  Iterable<K> get keys sync* {
    yield* _keys;
  }

  @override
  K? firstKey() => _keys.isNotEmpty ? _keys.first : null;

  @override
  K? firstKeyAfter(K key) {
    var i = bisectRight(_keys, key, _compare);
    return i < _keys.length ? _keys[i] : null;
  }

  @override
  K? lastKey() => _keys.isNotEmpty ? _keys.last : null;

  @override
  K? lastKeyBefore(K key) {
    var i = bisectLeft(_keys, key, _compare) - 1;
    return i >= 0 ? _keys[i] : null;
  }

  @override
  V? remove(Object? key) {
    if (key is! K || !_validKey(key)) return null;
    var i = bisectLeft(_keys, key, _compare);
    if (i == _keys.length || _compare(_keys[i], key) != 0) return null;
    _keys.removeAt(i);
    return _values.removeAt(i);
  }
}
