import 'dart:math';

import 'package:fangorn/src/util.dart';
import 'package:test/test.dart';

void main() {
  bisectLeftRandomTest(1000);
  bisectRightRandomTest(1000);
}

void bisectLeftRandomTest(int n) {
  test('random test of bisectLeft', () {
    var rnd = Random(0);
    var list = List.generate(n, (_) => rnd.nextInt(n));
    list.sort();
    for (var key = -1; key <= n; ++key) {
      var idx = bisectLeft(list, key, Comparable.compare);
      expect(idx == 0 || list[idx - 1] < key, isTrue);
      expect(idx == n || key <= list[idx], isTrue);
    }
  });
}

void bisectRightRandomTest(int n) {
  test('random test of bisectRight', () {
    var rnd = Random(0);
    var list = List.generate(n, (_) => rnd.nextInt(n));
    list.sort();
    for (var key = -1; key <= n; ++key) {
      var idx = bisectRight(list, key, Comparable.compare);
      expect(idx == 0 || list[idx - 1] <= key, isTrue);
      expect(idx == n || key < list[idx], isTrue);
    }
  });
}
