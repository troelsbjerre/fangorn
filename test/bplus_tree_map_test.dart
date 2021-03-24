import 'package:fangorn/bplus_tree_map.dart';

import 'common.dart';

void main() {
  randomIntInsertRemoveTest(BPlusTreeMap<int, int>(), 100);
  randomIntKeysTest(BPlusTreeMap<int, int>(), 1000);
  randomIntSplayConformityTest(BPlusTreeMap<int, int>(), 1000);
}
