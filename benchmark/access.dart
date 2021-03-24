import 'dart:collection';
import 'dart:math';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:fangorn/nested_list_map.dart';

class AccessBenchmark extends BenchmarkBase {
  AccessBenchmark(this.newmap, this.n, {Object param = ''})
      : super('${newmap().runtimeType}($param) $n ');
  Map<double, double> Function() newmap;
  int n;
  late Map<double, double> map;
  late List<double> keys;

  @override
  void setup() {
    var rnd = Random(0);
    keys = List.generate(n, (_) => rnd.nextDouble());
    map = newmap();
    for (var key in keys) {
      map[key] = key;
    }
  }

  @override
  void run() {
    for (var key in keys) {
      map[key] = key;
    }
  }
}

void main() {
  for (var n = 1 << 6; n <= 1 << 25; n <<= 1) {
    AccessBenchmark(() => SplayTreeMap<double, double>(), n).report();
    for (var lim = 100; lim <= 1000; lim += 100) {
      AccessBenchmark(() => NestedListMap<double, double>(limit: lim), n,
              param: lim)
          .report();
    }
  }
}
