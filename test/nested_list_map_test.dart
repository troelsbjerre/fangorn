import 'package:fangorn/nested_list_map.dart';

import 'common.dart';

void main() {
  randomIntInsertRemoveTest(NestedListMap<int, int>(limit: 10), 1000);
  randomIntKeysTest(NestedListMap<int, int>(limit: 10), 1000);
  randomIntSplayConformityTest(NestedListMap<int, int>(limit: 10), 1000);
}
