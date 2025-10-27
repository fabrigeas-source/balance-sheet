class Task {
  final String id;
  final String description;
  final String? details;
  final DateTime? dueDate;
  final DateTime createdAt;
  final String? parentId;
  final List<Task> children;
  final bool isCompleted;

  Task({
    required this.id,
    required this.description,
    this.details,
    this.dueDate,
    DateTime? createdAt,
    this.parentId,
    List<Task>? children,
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       children = children ?? [];

  Task copyWith({
    String? id,
    String? description,
    String? details,
    DateTime? dueDate,
    DateTime? createdAt,
    String? parentId,
    List<Task>? children,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      description: description ?? this.description,
      details: details ?? this.details,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'details': details,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'parentId': parentId,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      description: json['description'] as String,
      details: json['details'] as String?,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      parentId: json['parentId'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  String toString() =>
      'Task{id: $id, description: $description, dueDate: $dueDate, isCompleted: $isCompleted}';
}
