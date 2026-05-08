class TaskEntity {
  final String title;
  final bool completed;
  final String priority;
  final String status;
  final int duration;
  final String category;

  TaskEntity({
    required this.title,
    required this.completed,
    required this.priority,
    required this.status,
    required this.duration,
    required this.category,
  });

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      title: json['title']?.toString() ?? '',
      completed: json['completed'] == true,
      priority: json['priority']?.toString() ?? 'low',
      status: json['status']?.toString() ?? 'todo',
      duration: (json['duration'] is int)
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      category: json['category']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
      'priority': priority,
      'status': status,
      'duration': duration,
      'category': category,
    };
  }

  TaskEntity copyWith({
    String? title,
    bool? completed,
    String? priority,
    String? status,
    int? duration,
    String? category,
  }) {
    return TaskEntity(
      title: title ?? this.title,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      duration: duration ?? this.duration,
      category: category ?? this.category,
    );
  }

  bool matches(TaskEntity other) {
    return title == other.title &&
        completed == other.completed &&
        priority == other.priority &&
        status == other.status &&
        duration == other.duration &&
        category == other.category;
  }
}
