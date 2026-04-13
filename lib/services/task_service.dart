import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  TaskService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('tasks');

  Future<void> addTask(String name) async {
    final ref = _tasks.doc();
    final task = Task(
      id: ref.id,
      name: name,
      isComplete: false,
      subtasks: const [],
    );
    await ref.set(task.toMap());
  }

  Stream<List<Task>> streamTasks() {
    return _tasks.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Task.fromMap(data).copyWith(id: doc.id);
      }).toList();
    });
  }

  Future<void> updateTask(Task task) async {
    await _tasks.doc(task.id).set(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }

  Future<void> addSubtask(String taskId, String subtask) async {
    await _tasks.doc(taskId).update({
      'subtasks': FieldValue.arrayUnion([subtask]),
    });
  }

  Future<void> removeSubtask(String taskId, String subtask) async {
    await _tasks.doc(taskId).update({
      'subtasks': FieldValue.arrayRemove([subtask]),
    });
  }
}
