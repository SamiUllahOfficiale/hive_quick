import 'package:hive_flutter/hive_flutter.dart';
import 'security/key_vault.dart';

/// Manages storage operations for a specific box type in Hive.
class HiveQuickStore<T> {
  /// The name of the Hive box used for storage.
  final String boxName;

  final T Function(Map<String, dynamic> json) _fromJson;
  final Map<String, dynamic> Function(T object) _toJson;

  /// Whether the stored data is encrypted using AES-256.
  final bool secure;

  Box<Map>? _box;
  Box<List>? _orderBox;

  HiveQuickStore._({
    required this.boxName,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    this.secure = false,
  })  : _fromJson = fromJson,
        _toJson = toJson;

  /// Factory constructor to create an instance of [HiveQuickStore].
  factory HiveQuickStore.create({
    required String boxName,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    bool secure = false,
  }) {
    return HiveQuickStore._(
      boxName: boxName,
      fromJson: fromJson,
      toJson: toJson,
      secure: secure,
    );
  }

  Future<Box<Map>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;

    HiveCipher? cipher;
    if (secure) {
      final encryptionKey = await KeyVault.getOrCreateKey();
      cipher = HiveAesCipher(encryptionKey);
    }

    _box = await Hive.openBox<Map>(boxName, encryptionCipher: cipher);
    _orderBox = await Hive.openBox<List>('${boxName}_order');
    return _box!;
  }

  List<String> _getKeysOrder() {
    final list = _orderBox?.get('keys');
    if (list != null) {
      return List<String>.from(list);
    }
    return [];
  }

  Future<void> _saveKeysOrder(List<String> keys) async {
    await _orderBox?.put('keys', keys);
  }

  String? _extractId(dynamic item) {
    if (item is Map) {
      return item['id']?.toString() ??
          item['_id']?.toString() ??
          item['key']?.toString();
    }
    return null;
  }

  Future<dynamic> _internalSave(dynamic input, {String? key}) async {
    final box = await _getBox();

    Map<String, dynamic> inputMap;
    if (input is Map<String, dynamic>) {
      inputMap = Map<String, dynamic>.from(input);
    } else if (input is Map) {
      inputMap = Map<String, dynamic>.from(input);
    } else {
      inputMap = _toJson(input as T);
    }

    final targetKey = key ??
        _extractId(inputMap) ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final existingRaw = box.get(targetKey);
    final keysOrder = _getKeysOrder();

    Map<String, dynamic> finalMap;
    if (existingRaw != null) {
      final existingMap = Map<String, dynamic>.from(existingRaw);
      finalMap = {...existingMap, ...inputMap};
      await box.put(targetKey, finalMap);
    } else {
      finalMap = inputMap;
      await box.put(targetKey, finalMap);

      keysOrder.remove(targetKey);
      keysOrder.insert(0, targetKey);
      await _saveKeysOrder(keysOrder);
    }

    return input is Map ? finalMap : _fromJson(finalMap);
  }

  /// Fetches a single item by key.
  ///
  /// Returns `null` if the item is not found.
  Future<T?> findOne(String key) async {
    final box = await _getBox();
    final rawData = box.get(key);
    if (rawData == null) return null;
    return _fromJson(Map<String, dynamic>.from(rawData));
  }

  /// Fetches multiple items by keys, or all items if [keys] is `null` or empty.
  ///
  /// Always returns a strongly typed [List] of items.
  Future<List<T>> findMany([List<String>? keys]) async {
    final box = await _getBox();

    List<String> keysToFetch;
    if (keys != null && keys.isNotEmpty) {
      keysToFetch = keys;
    } else {
      keysToFetch = _getKeysOrder().where((k) => box.containsKey(k)).toList();
    }

    final list = <T>[];
    for (final k in keysToFetch) {
      final raw = box.get(k);
      if (raw != null) {
        list.add(_fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    return list;
  }

  /// Inserts or partially updates a single record.
  ///
  /// Accepts either a model instance or a [Map] containing partial update fields.
  Future<dynamic> updateOne(dynamic input, {String? key}) async {
    return await _internalSave(input, key: key);
  }

  /// Inserts or partially updates multiple records at once.
  ///
  /// Accepts a list of model instances or partial [Map] objects.
  Future<List<dynamic>> updateMany(List<dynamic> inputs) async {
    final list = <dynamic>[];
    for (final item in inputs) {
      final res = await _internalSave(item);
      list.add(res);
    }
    return list;
  }

  /// Deletes a single entry by key.
  Future<void> deleteOne(String key) async {
    final box = await _getBox();
    await box.delete(key);
    final keysOrder = _getKeysOrder();
    keysOrder.remove(key);
    await _saveKeysOrder(keysOrder);
  }

  /// Deletes multiple entries matching the provided list of [keys].
  Future<void> deleteMany(List<String> keys) async {
    final box = await _getBox();
    final keysOrder = _getKeysOrder();

    for (final key in keys) {
      await box.delete(key);
      keysOrder.remove(key);
    }
    await _saveKeysOrder(keysOrder);
  }

  /// Permanently removes all entries stored in this box.
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
    await _orderBox?.clear();
  }

  /// Listens for store updates and emits the full collection of items.
  Stream<List<T>> watchAll() async* {
    yield await findMany();
    final box = await _getBox();
    yield* box.watch().asyncMap((_) async => await findMany());
  }
}
