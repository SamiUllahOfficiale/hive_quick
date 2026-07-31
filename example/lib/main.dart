import 'package:flutter/material.dart';
import 'package:hive_quick/hive_quick.dart';
import 'models/task_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveQuick.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HiveQuick Task Creator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();

  final _taskStore = HiveQuick.store<TaskModel>(
    boxName: 'tasks',
    fromJson: TaskModel.fromJson,
    toJson: (task) => task.toJson(),
  );

  Future<void> _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await _taskStore.updateOne(
      TaskModel(id: id, title: text, isCompleted: false),
    );

    _taskController.clear();
    if (mounted) setState(() {});
  }

  Future<void> _toggleTask(TaskModel task) async {
    if (task.id == null) return;

    await _taskStore.updateOne(
      {
        'id': task.id,
        'isCompleted': !(task.isCompleted ?? false),
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _deleteOneTask(String id) async {
    await _taskStore.deleteOne(id);
    if (mounted) setState(() {});
  }

  Future<void> _clearAllTasks() async {
    await _taskStore.clearAll();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Quick Task Creator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
            onPressed: _clearAllTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task title...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: _taskStore.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Tasks Found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isDone = task.isCompleted ?? false;

                    return ListTile(
                      leading: Checkbox(
                        value: isDone,
                        onChanged: (_) => _toggleTask(task),
                      ),
                      title: Text(
                        task.title ?? '',
                        style: TextStyle(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          if (task.id != null) {
                            _deleteOneTask(task.id!);
                          }
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
