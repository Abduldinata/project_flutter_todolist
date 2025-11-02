class Task {
  final int id;
  final String title;
  final String? description;
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.isDone,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    isDone: json['is_done'] ?? false,
  );
}
