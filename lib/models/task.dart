class Task {
  final String id;
  final String name;
  final bool isComplete;
  final List<String> subtasks;

  const Task({
    required this.id,
    required this.name,
    required this.isComplete,
    required this.subtasks,
  });

  /// Serializes for [FirebaseFirestore] via [DocumentReference.set], [WriteBatch.set], etc.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'isComplete': isComplete,
      'subtasks': subtasks,
    };
  }

  /// Deserializes document [data]; use the snapshot’s document id for [id] when it is only stored in the path.
  factory Task.fromMap(Map<String, dynamic> map) {
    final rawSubtasks = map['subtasks'];
    return Task(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      isComplete: map['isComplete'] as bool? ?? false,
      subtasks: rawSubtasks is List
          ? rawSubtasks.map((e) => e.toString()).toList()
          : <String>[],
    );
  }

  Task copyWith({
    String? id,
    String? name,
    bool? isComplete,
    List<String>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      isComplete: isComplete ?? this.isComplete,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
