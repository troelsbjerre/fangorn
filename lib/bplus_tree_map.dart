import 'dart:collection';
import 'package:fangorn/src/util.dart';

class BPlusTreeMap<K, V> extends MapBase<K, V> implements SplayTreeMap<K, V> {
  _BPlusTree<K, V> _root;

  final Comparator<K> _compare;
  final Predicate<K> _validKey;

  BPlusTreeMap(
      {int Function(K key1, K key2)? compare,
      bool Function(K potentialKey)? isValidKey,
      int maxChildCount = 16})
      : _compare = compare ?? defaultCompare<K>(),
        _validKey = isValidKey ?? ((_) => true),
        _root = _BPlusLeaf(maxChildCount);

  @override
  V? operator [](Object? key) =>
      key is! K || !_validKey(key) ? null : _root.retrieve(key, _compare);

  @override
  void operator []=(K key, V value) {
    _root.insert(key, value, _compare);
    var part = _root._trySplit();
    if (part != null) {
      _root = _BPlusNode([_root, part]);
    }
    // assert(_root._assertInvariants(_compare));
  }

  @override
  void clear() => _root = _BPlusLeaf();

  @override
  K? firstKey() => _root.isEmpty ? null : _root.firstKey();

  @override
  K? firstKeyAfter(K key) => _root.firstKeyAfter(key, _compare);

  @override
  Iterable<K> get keys => _root.keys;

  @override
  K? lastKey() => _root.isEmpty ? null : _root.lastKey();

  @override
  K? lastKeyBefore(K key) => _root.lastKeyBefore(key, _compare);

  @override
  V? remove(Object? key) {
    if (key is! K || !_validKey(key)) return null;
    var retval = _root.remove(key, _compare);
    if (retval != null) _root = _root._tryCollapse();
    // assert(_root._assertInvariants(_compare));
    return retval;
  }
}

abstract class _BPlusTree<K, V> {
  final int _maxChildCount;
  _BPlusTree(this._maxChildCount);
  bool _assertInvariants(Comparator<K> compare);
  _BPlusTree<K, V>? _trySplit();
  bool _tryMerge(_BPlusTree<K, V> next);
  _BPlusTree<K, V> _tryCollapse();
  V? retrieve(K key, Comparator<K> compare);
  void insert(K key, V value, Comparator<K> compare);
  bool get isEmpty;
  bool get isNotEmpty => !isEmpty;
  K firstKey();
  K? firstKeyAfter(K key, Comparator<K> compare);
  Iterable<K> get keys;
  K lastKey();
  K? lastKeyBefore(K key, Comparator<K> compare);
  V? remove(K key, Comparator<K> compare);
}

class _BPlusNode<K, V> extends _BPlusTree<K, V> {
  final List<K> _lastkeys = [];
  final List<_BPlusTree<K, V>> _children = [];
  int _modificationCount = 0;

  _BPlusNode(Iterable<_BPlusTree<K, V>> children)
      : super(children.first._maxChildCount) {
    _children.addAll(children);
    _lastkeys.addAll(children.map((child) => child.lastKey()));
  }

  @override
  bool _assertInvariants(Comparator<K> compare) {
    assert(_lastkeys.length == _children.length);
    for (var i = 0; i < _children.length; ++i) {
      var child = _children[i];
      assert(child._assertInvariants(compare));
      assert(child.isNotEmpty);
      assert(_lastkeys[i] == child.lastKey());
    }
    for (var i = 1; i < _children.length; ++i) {
      assert(compare(_lastkeys[i - 1], _lastkeys[i]) < 0);
      assert(compare(_children[i - 1].lastKey(), _children[i].firstKey()) < 0);
    }
    return true;
  }

  @override
  V? retrieve(K key, Comparator<K> compare) {
    var idx = bisectLeft(_lastkeys, key, compare);
    if (idx == _lastkeys.length) return null;
    return _children[idx].retrieve(key, compare);
  }

  @override
  void insert(K key, V value, Comparator<K> compare) {
    var idx = bisectLeft(_lastkeys, key, compare);
    if (idx == _lastkeys.length) --idx;
    var newchild = (_children[idx]..insert(key, value, compare))._trySplit();
    if (newchild != null) {
      _children.insert(idx + 1, newchild);
      _lastkeys.insert(idx + 1, newchild.lastKey()!);
    }
    _lastkeys[idx] = _children[idx].lastKey()!;
    ++_modificationCount;
  }

  @override
  bool get isEmpty => _children.isEmpty;

  @override
  _BPlusTree<K, V> _tryCollapse() =>
      _children.length == 1 ? _children.single : this;

  @override
  bool _tryMerge(_BPlusTree<K, V> next) {
    var nextNode = next as _BPlusNode<K, V>;
    if (_children.length + nextNode._children.length <= _maxChildCount ~/ 2) {
      _children.addAll(nextNode._children);
      _lastkeys.addAll(nextNode._lastkeys);
      return true;
    }
    return false;
  }

  @override
  _BPlusTree<K, V>? _trySplit() {
    if (_children.length == _maxChildCount) {
      var next = _BPlusNode<K, V>(_children.sublist(_maxChildCount ~/ 2));
      _children.length = _maxChildCount ~/ 2;
      _lastkeys.length = _maxChildCount ~/ 2;
      return next;
    }
    return null;
  }

  @override
  K firstKey() => _children.first.firstKey();

  @override
  K? firstKeyAfter(K key, Comparator<K> compare) {
    var idx = bisectRight(_lastkeys, key, compare);
    if (idx == _children.length) return null;
    return _children[idx].firstKeyAfter(key, compare);
  }

  @override
  Iterable<K> get keys sync* {
    var expectedModificationCount = _modificationCount;
    for (var child in _children) {
      if (_modificationCount != expectedModificationCount) {
        throw ConcurrentModificationError();
      }
      yield* child.keys;
    }
  }

  @override
  K lastKey() => _lastkeys.last;

  @override
  K? lastKeyBefore(K key, Comparator<K> compare) {
    var idx = bisectLeft(_lastkeys, key, compare);
    if (idx == _lastkeys.length) return _lastkeys.last;
    var retval = _children[idx].lastKeyBefore(key, compare);
    return retval == null && idx > 0 ? _lastkeys[idx - 1] : retval;
  }

  @override
  V? remove(K key, Comparator<K> compare) {
    var idx = bisectLeft(_lastkeys, key, compare);
    if (idx == _lastkeys.length) return null;
    ++_modificationCount;
    var retval = _children[idx].remove(key, compare);
    if (idx > 0 && _children[idx - 1]._tryMerge(_children[idx])) {
      _children.removeAt(idx);
      _lastkeys.removeAt(idx);
      --idx;
    }
    if (idx + 1 < _children.length &&
        _children[idx]._tryMerge(_children[idx + 1])) {
      _children.removeAt(idx + 1);
      _lastkeys.removeAt(idx + 1);
    }
    _lastkeys[idx] = _children[idx].lastKey();
    return retval;
  }
}

class _BPlusLeaf<K, V> extends _BPlusTree<K, V> {
  final List<K> _keys;
  final List<V> _values;

  _BPlusLeaf([int maxChildCount = 10])
      : _keys = [],
        _values = [],
        super(maxChildCount);

  _BPlusLeaf.of(this._keys, this._values, int maxChildCount)
      : super(maxChildCount);

  @override
  bool _assertInvariants(Comparator<K> compare) {
    assert(_keys.length == _values.length);
    for (var i = 1; i < _keys.length; ++i) {
      assert(compare(_keys[i - 1], _keys[i]) < 0);
    }
    return true;
  }

  @override
  V? retrieve(K key, Comparator<K> compare) {
    var idx = bisectLeft(_keys, key, compare);
    if (idx == _keys.length) return null;
    return compare(key, _keys[idx]) == 0 ? _values[idx] : null;
  }

  @override
  void insert(K key, V value, Comparator<K> compare) {
    var idx = bisectLeft(_keys, key, compare);
    if (idx < _keys.length && compare(key, _keys[idx]) == 0) {
      _values[idx] = value;
    } else {
      _keys.insert(idx, key);
      _values.insert(idx, value);
    }
  }

  @override
  bool get isEmpty => _keys.isEmpty;

  @override
  _BPlusTree<K, V> _tryCollapse() => this;

  @override
  bool _tryMerge(_BPlusTree<K, V> next) {
    var nextLeaf = next as _BPlusLeaf<K, V>;
    if (_values.length + nextLeaf._values.length <= _maxChildCount ~/ 2) {
      _keys.addAll(nextLeaf._keys);
      _values.addAll(nextLeaf._values);
      return true;
    } else {
      return false;
    }
  }

  @override
  _BPlusTree<K, V>? _trySplit() {
    if (_keys.length < _maxChildCount) return null;
    var nextLeaf = _BPlusLeaf.of(_keys.sublist(_maxChildCount ~/ 2),
        _values.sublist(_maxChildCount ~/ 2), _maxChildCount);
    _keys.length = _maxChildCount ~/ 2;
    _values.length = _maxChildCount ~/ 2;
    return nextLeaf;
  }

  @override
  K firstKey() => _keys.first;

  @override
  K? firstKeyAfter(K key, Comparator<K> compare) {
    var idx = bisectRight(_keys, key, compare);
    return idx < _keys.length ? _keys[idx] : null;
  }

  @override
  Iterable<K> get keys sync* {
    yield* _keys;
  }

  @override
  K lastKey() => _keys.last;

  @override
  K? lastKeyBefore(K key, Comparator<K> compare) {
    var idx = bisectLeft(_keys, key, compare) - 1;
    return idx >= 0 ? _keys[idx] : null;
  }

  @override
  V? remove(K key, Comparator<K> compare) {
    var idx = bisectLeft(_keys, key, compare);
    if (idx == _keys.length || compare(key, _keys[idx]) != 0) return null;
    _keys.removeAt(idx);
    return _values.removeAt(idx);
  }
}
