class Task {
  final int id;
  final String userId;
  final String title;
  final String? description;
  final DateTime date;  // ✅ TAMBAHKAN
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,  // ✅ TAMBAHKAN
    required this.isDone,
    required this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',  // ✅ DEFAULT VALUE
      description: json['description'],
      date: DateTime.parse(json['date']),  // ✅ PARSE DATE
      isDone: json['is_done'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T')[0],  // ✅ Format YYYY-MM-DD
      'is_done': isDone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}