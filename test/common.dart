import 'dart:collection';
import 'dart:math';

import 'package:test/test.dart';

void randomIntInsertRemoveTest(Map<int, int> testMap, int n) {
  var rnd = Random(0);
  randomInsertRemoveTest(
      testMap, n, () => rnd.nextInt(n), () => rnd.nextInt(n));
}

void randomInsertRemoveTest<K, V>(
    Map<K, V> testMap, int n, K Function() keyGen, V Function() valueGen) {
  test('random insert test of ${testMap.runtimeType}', () {
    var keys = List.generate(n, (_) => keyGen());
    var targetMap = <K, V>{};
    for (var key in keys) {
      var value = valueGen();
      expect(testMap[key], targetMap[key]);
      testMap[key] = value;
      targetMap[key] = value;
    }
    // expect(testMap.length, targetMap.length);
    keys.shuffle(Random(0));
    for (var key in keys) {
      expect(testMap.remove(key), targetMap.remove(key));
      expect(testMap.length, targetMap.length);
    }
  });
}

void randomIntKeysTest(Map<int, int> testMap, int n) {
  var rnd = Random(0);
  randomKeysTest(testMap, n, () => rnd.nextInt(n), () => rnd.nextInt(n));
}

void randomKeysTest<K, V>(
    Map<K, V?> testMap, int n, K Function() keyGen, V Function() valueGen) {
  test('random keys order test of ${testMap.runtimeType}', () {
    var targetMap = SplayTreeMap<K, V>();
    var value = valueGen();
    for (var i = 0; i < n; ++i) {
      var key = keyGen();
      testMap[key] = value;
      targetMap[key] = value;
    }
    expect([...testMap.keys], [...targetMap.keys]);
  });
}

void randomIntSplayConformityTest(SplayTreeMap<int, int> testMap, int n) {
  var rnd = Random(0);
  randomSplayConformityTest(
      testMap, n, () => rnd.nextInt(n), () => rnd.nextInt(n));
}

void randomSplayConformityTest<K, V>(SplayTreeMap<K, V> testMap, int n,
    K Function() keyGen, V Function() valueGen) {
  test('random splay conformity test of ${testMap.runtimeType}', () {
    var targetMap = SplayTreeMap<K, V>();
    var keys = List.generate(n, (_) => keyGen());
    for (var key in keys) {
      var value = valueGen();
      expect(testMap[key], targetMap[key]);
      expect(testMap.firstKey(), targetMap.firstKey());
      expect(testMap.firstKeyAfter(key), targetMap.firstKeyAfter(key));
      expect(testMap.lastKey(), targetMap.lastKey());
      expect(testMap.lastKeyBefore(key), targetMap.lastKeyBefore(key));
      testMap[key] = value;
      targetMap[key] = value;
      key = keyGen();
      expect(testMap.remove(key), targetMap.remove(key));
    }
    keys.shuffle(Random(0));
    for (var key in keys) {
      expect(testMap.remove(key), targetMap.remove(key));
      expect(testMap[key], targetMap[key]);
      expect(testMap.firstKey(), targetMap.firstKey());
      expect(testMap.firstKeyAfter(key), targetMap.firstKeyAfter(key));
      expect(testMap.lastKey(), targetMap.lastKey());
      expect(testMap.lastKeyBefore(key), targetMap.lastKeyBefore(key));
    }
  });
}
