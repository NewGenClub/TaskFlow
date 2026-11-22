
class Task {
  final int? id;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Task({
    this.id,
    required this.title,
    this.description = '',
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
    };
  }
}
