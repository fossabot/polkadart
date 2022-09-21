import 'types_hashing.dart' show getTypeHash;
import 'dart:typed_data';
import 'types.dart' show Type;
import 'utils/utils.dart' show sha256;

class StorageItem {
  List<String> hashers;
  List<int> keys;
  int value;

  /// "Optional" or "Default" or "Required"
  String modifier;
  Uint8List fallback;
  List<String>? docs;

  StorageItem({
    required this.hashers,
    required this.keys,
    required this.value,
    required this.modifier,
    required this.fallback,
    this.docs,
  });
}

String getStorageItemTypeHash(List<Type> types, StorageItem item) {
  return sha256(<String, dynamic>{
    'keys': item.keys.map((k) => getTypeHash(types, k)).toList(),
    'value': getTypeHash(types, item.value),
    'optional': item.modifier == 'Optional',
  });
}
