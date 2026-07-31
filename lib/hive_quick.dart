/// A lightweight, developer-friendly local storage wrapper around Hive.
library hive_quick;

import 'package:hive_flutter/hive_flutter.dart';
import 'src/hive_quick_store.dart';

export 'src/hive_quick_store.dart';

/// Entry point for initializing and accessing HiveQuick stores.
class HiveQuick {
  /// Initializes Hive for Flutter applications.
  ///
  /// Call this inside `main()` before `runApp()`.
  static Future<void> init([String? subDir]) async {
    await Hive.initFlutter(subDir);
  }

  /// Creates and returns a typed [HiveQuickStore] instance.
  static HiveQuickStore<T> store<T>({
    required String boxName,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T object) toJson,
    bool secure = false,
  }) {
    return HiveQuickStore<T>.create(
      boxName: boxName,
      fromJson: fromJson,
      toJson: toJson,
      secure: secure,
    );
  }
}
