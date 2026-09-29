class UserModel {
  final String uid;
  final String name;
  final String email;

  final int productivityScore;
  final int completedTasks;
  final int pendingTasks;
  final double focusHours;

  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.productivityScore,
    required this.completedTasks,
    required this.pendingTasks,
    required this.focusHours,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      productivityScore: map["productivityScore"] ?? 0,
      completedTasks: map["completedTasks"] ?? 0,
      pendingTasks: map["pendingTasks"] ?? 0,
      focusHours: (map["focusHours"] ?? 0).toDouble(),
      createdAt: map["createdAt"] != null
          ? map["createdAt"].toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "productivityScore": productivityScore,
      "completedTasks": completedTasks,
      "pendingTasks": pendingTasks,
      "focusHours": focusHours,
      "createdAt": createdAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    int? productivityScore,
    int? completedTasks,
    int? pendingTasks,
    double? focusHours,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      productivityScore:
      productivityScore ?? this.productivityScore,
      completedTasks:
      completedTasks ?? this.completedTasks,
      pendingTasks:
      pendingTasks ?? this.pendingTasks,
      focusHours:
      focusHours ?? this.focusHours,
      createdAt:
      createdAt ?? this.createdAt,
    );
  }
}