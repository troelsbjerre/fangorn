import 'dart:collection';

import 'package:fangorn/src/util.dart';

class NestedListMap<K, V> extends MapBase<K, V> implements SplayTreeMap<K, V> {
  final List<List<K>> _keys = [];
  final List<List<V>> _values = [];
  final List<K> _lastkeys = [];
  final Comparator<K> _compare;
  final Predicate<K> _validKey;
  int _modificationCount = 0;
  final int _limit;

  NestedListMap(
      {int Function(K, K)? compare, bool Function(K)? isValidKey, int? limit})
      : _compare = compare ?? defaultCompare<K>(),
        _validKey = isValidKey ?? ((_) => true),
        _limit = limit ?? 256;

  bool _validate() {
    if (_keys.length != _lastkeys.length || _keys.length != _values.length) {
      return false;
    }
    for (var i = 0; i < _keys.length; ++i) {
      if (_keys[i].last != _lastkeys[i]) {
        return false;
      }
      if (_keys[i].length != _values[i].length) {
        return false;
      }
    }
    for (var keys in _keys) {
      for (var i = 1; i < keys.length; ++i) {
        if (_compare(keys[i - 1], keys[i]) >= 0) {
          return false;
        }
      }
    }
    for (var i = 1; i < _keys.length; ++i) {
      if (_compare(_keys[i - 1].last, _keys[i].first) >= 0) {
        return false;
      }
    }
    return true;
  }

  @override
  V? operator [](Object? key) {
    if (key is! K) return null;
    var i1 = bisectLeft(_lastkeys, key, _compare);
    if (i1 == _lastkeys.length) return null;
    var keys = _keys[i1];
    var i2 = bisectLeft(keys, key, _compare);
    return _compare(keys[i2], key) == 0 ? _values[i1][i2] : null;
  }

  @override
  void operator []=(key, value) {
    if (_keys.isEmpty) {
      _keys.add([key]);
      _lastkeys.add(key);
      _values.add([value]);
    } else {
      var i1 = bisectLeft(_lastkeys, key, _compare);
      if (i1 == _lastkeys.length) i1 -= 1;
      var keys = _keys[i1];
      var values = _values[i1];
      var i2 = bisectLeft(keys, key, _compare);
      if (i2 < keys.length && _compare(keys[i2], key) == 0) {
        _values[i1][i2] = value;
      } else {
        if (keys.length >= _limit) {
          var split = _limit ~/ 2;
          _keys.insert(i1 + 1, keys.sublist(split));
          keys.removeRange(split, keys.length);
          _values.insert(i1 + 1, values.sublist(split));
          values.removeRange(split, values.length);
          _lastkeys.insert(i1, keys[split - 1]);
          if (i2 >= split) {
            ++i1;
            i2 -= split;
            keys = _keys[i1];
            values = _values[i1];
          }
        }
        keys.insert(i2, key);
        _lastkeys[i1] = keys.last;
        values.insert(i2, value);
      }
    }
    ++_modificationCount;
  }

  @override
  void clear() {
    _keys.clear();
    _lastkeys.clear();
    _values.clear();
  }

  @override
  Iterable<K> get keys sync* {
    var expectedModificationCount = _modificationCount;
    for (var keys in _keys) {
      if (expectedModificationCount != _modificationCount) {
        throw ConcurrentModificationError(this);
      }
      yield* keys;
    }
  }

  @override
  K? firstKey() {
    return isNotEmpty ? _keys.first.first : null;
  }

  @override
  K? firstKeyAfter(K key) {
    var i1 = bisectRight(_lastkeys, key, _compare);
    if (i1 == _lastkeys.length) return null;
    var keys = _keys[i1];
    var i2 = bisectRight(keys, key, _compare);
    return keys[i2];
  }

  @override
  K? lastKey() {
    return isNotEmpty ? _keys.last.last : null;
  }

  @override
  K? lastKeyBefore(K key) {
    var i1 = bisectLeft(_lastkeys, key, _compare);
    if (i1 == _lastkeys.length) --i1;
    if (i1 < 0) return null;
    var keys = _keys[i1];
    var i2 = bisectLeft(keys, key, _compare) - 1;
    if (i2 == -1) {
      return i1 > 0 ? _lastkeys[i1 - 1] : null;
    }
    return keys[i2];
  }

  @override
  V? remove(Object? key) {
    if (key is! K || !_validKey(key)) return null;
    var i1 = bisectLeft(_lastkeys, key, _compare);
    if (i1 == _lastkeys.length) return null;
    var keys = _keys[i1];
    var values = _values[i1];
    var i2 = bisectLeft(keys, key, _compare);
    if (i2 == keys.length) return null;
    if (_compare(key, keys[i2]) == 0) {
      keys.removeAt(i2);
      var retval = values.removeAt(i2);
      if (i1 > 0 && _keys[i1 - 1].length + keys.length < _limit / 2) {
        _keys[i1 - 1].addAll(keys);
        _values[i1 - 1].addAll(values);
        _lastkeys[i1 - 1] = _keys[i1 - 1].last;
        _keys.removeAt(i1);
        _values.removeAt(i1);
        _lastkeys.removeAt(i1);
      } else if (i1 + 1 < _keys.length &&
          keys.length + _keys[i1 + 1].length < _limit / 2) {
        keys.addAll(_keys[i1 + 1]);
        values.addAll(_values[i1 + 1]);
        _lastkeys[i1] = keys.last;
        _keys.removeAt(i1 + 1);
        _values.removeAt(i1 + 1);
        _lastkeys.removeAt(i1 + 1);
      } else if (keys.isEmpty) {
        _keys.removeAt(i1);
        _values.removeAt(i1);
        _lastkeys.removeAt(i1);
      } else {
        _lastkeys[i1] = _keys[i1].last;
      }
      return retval;
    }
    return null;
  }
}
