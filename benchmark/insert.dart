import 'dart:collection';
import 'dart:math';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:fangorn/bplus_tree_map.dart';
import 'package:fangorn/nested_list_map.dart';

class InsertBenchmark extends BenchmarkBase {
  InsertBenchmark(this.newmap, this.n, {Object param = ''})
      : super('${newmap().runtimeType}($param) $n ');
  Map<double, double> Function() newmap;
  int n;
  late List<double> keys;

  @override
  void setup() {
    var rnd = Random(0);
    keys = List.generate(n, (_) => rnd.nextDouble());
  }

  @override
  void run() {
    var map = newmap();
    for (var key in keys) {
      map[key] = key;
    }
  }
}

void main() {
  for (var n = 128; n <= 10000000; n *= 2) {
    InsertBenchmark(() => SplayTreeMap<double, double>(), n).report();
    InsertBenchmark(() => BPlusTreeMap<double, double>(), n).report();
    InsertBenchmark(() => NestedListMap<double, double>(), n).report();
  }
}
