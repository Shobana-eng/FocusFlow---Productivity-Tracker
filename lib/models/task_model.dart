class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;
  final String priority;
  final String category;
  final double progress;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.isCompleted,
    required this.priority,
    required this.category,
    required this.progress,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map["title"] ?? "",
      description: map["description"] ?? "",
      date: map["date"].toDate(),
      isCompleted: map["isCompleted"] ?? false,
      priority: map["priority"] ?? "Medium",
      category: map["category"] ?? "General",
      progress: (map["progress"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date,
      "isCompleted": isCompleted,
      "priority": priority,
      "category": category,
      "progress": progress,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isCompleted,
    String? priority,
    String? category,
    double? progress,
  }) {
    return
      TaskModel
        (
        id
            :
        id
            ??
            this
                .
            id
        ,
        title
            :
        title
            ??
            this
                .
            title
        ,
        description
            :
        description
            ??
            this
                .
            description
        ,
        date
            :
        date
            ??
            this
                .
            date
        ,
        isCompleted
            :
        isCompleted
            ??
            this
                .
            isCompleted
        ,
        priority
            :
        priority
            ??
            this
                .
            priority
        ,
        category
            :
        category
            ??
            this
                .
            category
        ,
        progress
            :
        progress
            ??
            this
                .
            progress
        ,
      );
  }
}


