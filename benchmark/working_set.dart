import 'dart:collection';
import 'dart:math';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:fangorn/nested_list_map.dart';
import 'package:fangorn/resizing_list_map.dar';

class WorkingSetBenchmark extends BenchmarkBase {
  WorkingSetBenchmark(this.newmap, this.n, {Object param = ''})
      : super('${newmap().runtimeType}($param) $n ');
  Map<double, double> Function() newmap;
  int n;
  late Map<double, double> map;

  @override
  void setup() {
    var rnd = Random(0);
    map = newmap();
    for (var i = 0; i < n * n; ++i) {
      map[rnd.nextDouble()] = rnd.nextDouble();
    }
  }

  @override
  void run() {
    var rnd = Random(0);
    for (var i = 0; i < n; ++i) {
      map[rnd.nextDouble()] = rnd.nextDouble();
    }
  }
}

void main() {
  for (var n = 1 << 3; n <= 1 << 11; n <<= 1) {
    WorkingSetBenchmark(() => SplayTreeMap<double, double>(), n).report();
    WorkingSetBenchmark(() => NestedListMap<double, double>(limit: 100), n,
            param: 100)
        .report();
    WorkingSetBenchmark(() => NestedListMap<double, double>(limit: 200), n,
            param: 200)
        .report();
    WorkingSetBenchmark(() => ResizingListMap<double, double>(), n).report();
  }
}
