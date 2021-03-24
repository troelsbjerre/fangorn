typedef Predicate<T> = bool Function(T value);

// finds 0 <= i <= list.length : list[i-1] < key <= list[i]
int bisectLeft<K>(List<K> list, K key, Comparator<K> compare) {
  var lo = -1;
  var hi = list.length;
  while (hi - lo > 1) {
    var mi = lo + (hi - lo) ~/ 2;
    if (compare(list[mi], key) < 0) {
      lo = mi;
    } else {
      hi = mi;
    }
  }
  return hi;
}

// finds 0 <= i <= list.length : list[i-1] <= key < list[i]
int bisectRight<K>(List<K> list, K key, Comparator<K> compare) {
  var lo = -1;
  var hi = list.length;
  while (hi - lo > 1) {
    var mi = lo + (hi - lo) ~/ 2;
    if (compare(list[mi], key) <= 0) {
      lo = mi;
    } else {
      hi = mi;
    }
  }
  return hi;
}

int _dynamicCompare(dynamic a, dynamic b) => Comparable.compare(a, b);

Comparator<K> defaultCompare<K>() {
  // If K <: Comparable, then we can just use Comparable.compare
  // with no casts.
  Object compare = Comparable.compare;
  if (compare is Comparator<K>) {
    return compare;
  }
  // Otherwise wrap and cast the arguments on each call.
  return _dynamicCompare;
}
