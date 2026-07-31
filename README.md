# Hive Quick

A lightweight, developer-friendly local storage library built on top of **Hive** with MongoDB/Mongoose-style API methods. Designed for high developer productivity, type safety, partial object updates, and zero boilerplate.

---

## Features

- 🚀 **Intuitive API**: Use clean methods like `findOne`, `findMany`, `updateOne`, `updateMany`, `deleteOne`, `deleteMany`, and `clearAll`.
- ⚡ **Partial Updates**: Update specific fields using raw `Map` objects without overwriting existing data.
- 📌 **Order Preservation**: Automatically keeps newly added records at top/first position.
- 🔐 **Secure Encryption**: Built-in AES-256 encryption via `flutter_secure_storage`.
- 📡 **Reactive Streams**: Observe collection updates in real time using `watchAll()`.

---

## Quick Start

Add `hive_quick` to your `pubspec.yaml`:

```yaml
dependencies:
  hive_quick: ^1.0.0
```

Initialize HiveQuick inside your `main()` method before `runApp()`:

```dart
import 'package:flutter/material.dart';
import 'package:hive_quick/hive_quick.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveQuick.init();
  runApp(const MyApp());
}
```

## Usage

Define a Model
Define your data model with standard `fromJson` and `toJson` methods:

```dart
class TaskModel {
  final String? id;
  final String? title;
  final bool? isCompleted;

  TaskModel({this.id, this.title, this.isCompleted});

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      isCompleted: json['isCompleted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };
}
```

## Initialize a Store

Create a strongly typed store instance:

```dart
final taskStore = HiveQuick.store<TaskModel>(
  boxName: 'tasks',
  fromJson: TaskModel.fromJson,
  toJson: (task) => task.toJson(),
  secure: false, // Set to true to enable AES-256 encryption
);
```

## Create & Partial Updates (`updateOne` & `updateMany`)

```dart
await taskStore.updateOne(
  TaskModel(id: '1', title: 'Buy groceries', isCompleted: false),
);

await taskStore.updateOne({
  'id': '1',
  'isCompleted': true,
});

await taskStore.updateMany([
  TaskModel(id: '2', title: 'Walk the dog', isCompleted: false),
  TaskModel(id: '3', title: 'Clean desk', isCompleted: false),
]);
```

## Read Operations (`findOne` & `findMany`)

```dart
final TaskModel? task = await taskStore.findOne('1');
final List<TaskModel> selectedTasks = await taskStore.findMany(['1', '2']);
final List<TaskModel> allTasks = await taskStore.findMany();
```

## Delete Operations (`deleteOne`, `deleteMany`, `clearAll`)

```dart
await taskStore.deleteOne('1');
await taskStore.deleteMany(['2', '3']);
await taskStore.clearAll();
```

## Reactive State Stream (`watchAll`)

Use `watchAll()` with a `StreamBuilder` to reactively update UI elements when store data changes:

```dart
StreamBuilder<List<TaskModel>>(
  stream: taskStore.watchAll(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }

    final tasks = snapshot.data!;
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(tasks[index].title ?? ''),
        );
      },
    );
  },
);
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
