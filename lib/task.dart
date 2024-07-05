class Task {
  final String id;
  final String title;
  final String description;
  bool isDone;
  final DateTime? duedate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    this.duedate,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'] ?? false,
      duedate: json['duedate'] != null ? DateTime.parse(json['duedate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
