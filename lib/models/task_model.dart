class Task {
  final int id;
  final String userId;
  final String title;
  final String? description;
  final DateTime date;
  final String priority;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
    required this.priority,
    required this.isDone,
    required this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      description: json['description'],
      // Fix: Gunakan tryParse dengan fallback untuk menghindari crash
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      priority: json['priority'] ?? 'medium',
      isDone: json['is_done'] ?? false,
      // Fix: Gunakan tryParse dengan fallback untuk menghindari crash
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'priority': priority,
      'is_done': isDone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
