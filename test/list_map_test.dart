import 'package:fangorn/list_map.dart';

import 'common.dart';

void main() {
  randomIntInsertRemoveTest(ListMap<int, int>(), 1000);
  randomIntKeysTest(ListMap<int, int>(), 1000);
  randomIntSplayConformityTest(ListMap<int, int>(), 1000);
}
