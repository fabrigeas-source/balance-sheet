import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: 'task-1',
      description: 'Complete project documentation',
      details: 'Write comprehensive documentation for the project',
      dueDate: DateTime.now().add(const Duration(days: 7)),
    ),
    Task(
      id: 'task-2',
      description: 'Review pull requests',
      details: 'Review and merge pending pull requests',
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    Task(
      id: 'task-3',
      description: 'Update dependencies',
      details: 'Update all project dependencies to latest versions',
    ),
  ];

  List<Task> get tasks => List.unmodifiable(_tasks.where((task) => task.parentId == null));
  
  List<Task> getChildrenForTask(String parentId) {
    return _tasks.where((task) => task.parentId == parentId).toList();
  }
  
  int getSubTasksCount(String parentId) {
    return getChildrenForTask(parentId).length;
  }

  void createSubList(String parentId, Task newTask) {
    final subTask = newTask.copyWith(
      parentId: parentId,
      id: DateTime.now().toIso8601String(),
    );
    _tasks.add(subTask);
    notifyListeners();
  }

  void addTask(Task task, BuildContext context) {
    _tasks.add(task);
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task added successfully'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void updateTask(String id, Task updatedTask, BuildContext context) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
    }
  }

  void deleteTask(String id, BuildContext context) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task deleted'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  Task? getTask(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }
}
