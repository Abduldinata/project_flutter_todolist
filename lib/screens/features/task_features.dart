import 'package:flutter/material.dart';

class TaskFeatures {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  TaskFeatures({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
  });
}

class TaskListScreen extends StatefulWidget {
  
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<TaskFeatures> tasks = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  void addTask(String title, String description) {
    setState(() {
      tasks.add(TaskFeatures(
        id: DateTime.now().toString(),
        title: title,
        description: description,
        isCompleted: false,
        createdAt: DateTime.now(),
      ));
    });
    titleController.clear();
    descController.clear();
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index] = TaskFeatures(
        id: tasks[index].id,
        title: tasks[index].title,
        description: tasks[index].description,
        isCompleted: !tasks[index].isCompleted,
        createdAt: tasks[index].createdAt,
      );
    });
  }

  void deleteTask(int index) {
    setState(() => tasks.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Tasks')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Task Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => addTask(titleController.text, descController.text),
                  child: Text('Add Task'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: tasks[index].isCompleted,
                    onChanged: (_) => toggleTask(index),
                  ),
                  title: Text(tasks[index].title),
                  subtitle: Text(tasks[index].description),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}