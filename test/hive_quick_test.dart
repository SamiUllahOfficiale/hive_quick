import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_quick/hive_quick.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tempDir = Directory.systemTemp.createTempSync('hive_quick_test');

  setUpAll(() async {
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('HiveQuick Explicit API Tests', () {
    final store = HiveQuick.store<Map<String, dynamic>>(
      boxName: 'explicit_test_box',
      fromJson: (json) => json,
      toJson: (item) => item,
    );

    tearDown(() async {
      await store.clearAll();
    });

    test('updateOne and findOne with partial updates', () async {
      await store.updateOne({'id': '1', 'name': 'John', 'role': 'Admin'});
      await store.updateOne({'id': '1', 'role': 'SuperAdmin'});

      final user = await store.findOne('1');
      expect(user, isNotNull);
      expect(user!['name'], equals('John'));
      expect(user['role'], equals('SuperAdmin'));
    });

    test('updateMany and findMany batch operations', () async {
      await store.updateMany([
        {'id': '10', 'title': 'Task 10'},
        {'id': '20', 'title': 'Task 20'},
      ]);

      final allTasks = await store.findMany();
      expect(allTasks.length, equals(2));

      final selectedTasks = await store.findMany(['20']);
      expect(selectedTasks.length, equals(1));
      expect(selectedTasks.first['title'], equals('Task 20'));
    });

    test('deleteOne, deleteMany, and clearAll operations', () async {
      await store.updateMany([
        {'id': 'a', 'val': 'A'},
        {'id': 'b', 'val': 'B'},
        {'id': 'c', 'val': 'C'},
      ]);

      await store.deleteOne('a');
      expect(await store.findOne('a'), isNull);

      await store.deleteMany(['b']);
      expect(await store.findOne('b'), isNull);

      await store.clearAll();
      expect(await store.findMany(), isEmpty);
    });
  });
}
