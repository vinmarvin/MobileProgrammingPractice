class FocusCategory {
  final int? id;
  final String name;

  FocusCategory({this.id, required this.name});

  factory FocusCategory.fromMap(Map<String, dynamic> map) {
    return FocusCategory(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class FocusHistory {
  final int? id;
  final String taskName;
  final int durationMinutes;
  final String date;
  final int categoryId;
  final String? categoryName; // Digunakan saat query JOIN dengan categories

  FocusHistory({
    this.id,
    required this.taskName,
    required this.durationMinutes,
    required this.date,
    required this.categoryId,
    this.categoryName,
  });

  factory FocusHistory.fromMap(Map<String, dynamic> map) {
    return FocusHistory(
      id: map['id'],
      taskName: map['task_name'],
      durationMinutes: map['duration_minutes'],
      date: map['date'],
      categoryId: map['category_id'],
      categoryName: map['category_name'], // Bisa null jika tidak join
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_name': taskName,
      'duration_minutes': durationMinutes,
      'date': date,
      'category_id': categoryId,
    };
  }
}
