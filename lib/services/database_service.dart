import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================
  // USER
  // ===========================================================

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
      "createdAt": FieldValue.serverTimestamp(),

      // Analytics
      "productivityScore": 0,
      "completedTasks": 0,
      "pendingTasks": 0,
      "focusHours": 0,

      // Rewards
      "rewardPoints": 0,
      "xp": 0,
      "level": 1,
      "streak": 0,
      "badges": [],
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    return _firestore.collection("users").doc(uid).get();
  }

  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection("users").doc(uid).update(data);
  }

  // ===========================================================
  // TASKS
  // ===========================================================

  Future<void> addTask({
    required String uid,
    required Map<String, dynamic> taskData,
  }) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .add(taskData);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks(String uid) {
    return _firestore
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .orderBy("date")
        .snapshots();
  }

  Future<void> updateTask({
    required String uid,
    required String taskId,
    required bool completed,
  }) async {
    try {
      final taskRef = _firestore
          .collection("users")
          .doc(uid)
          .collection("tasks")
          .doc(taskId);

      final taskDoc = await taskRef.get();

      if (!taskDoc.exists) return;

      final data = taskDoc.data()!;
      bool alreadyCompleted = data["completed"] ?? false;

      await taskRef.update({
        "completed": completed,
      });

      if (completed && !alreadyCompleted) {
        await rewardTaskCompletion(uid);
      }
    } catch (e) {
      rethrow;
    }
  }
  Future<void> deleteTask({
    required String uid,
    required String taskId,
  }) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("tasks")
        .doc(taskId)
        .delete();
  }

  // ===========================================================
  // ANALYTICS
  // ===========================================================

  Future<void> updateAnalytics({
    required String uid,
    required double productivityScore,
    required int completedTasks,
    required int pendingTasks,
    required double focusHours,
  }) async {
    await _firestore.collection("users").doc(uid).update({
      "productivityScore": productivityScore,
      "completedTasks": completedTasks,
      "pendingTasks": pendingTasks,
      "focusHours": focusHours,
    });
  }

  Future<void> saveAiPrediction({
    required String uid,
    required double score,
    required String level,
    required double studyHours,
    required double sleepHours,
    required double screenTime,
    required List<String> recommendations,
  }) async {
    // 1. Save to history
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("productivity_history")
        .add({
      "score": score,
      "level": level,
      "studyHours": studyHours,
      "sleepHours": sleepHours,
      "screenTime": screenTime,
      "recommendations": recommendations,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // 2. Update user doc
    final docRef = _firestore.collection("users").doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    List badges = List.from(data["badges"] ?? []);

    bool badgesUpdated = false;
    if (score >= 80 && !badges.contains("Productivity Pro")) {
      badges.add("Productivity Pro");
      badgesUpdated = true;
    }
    if (score >= 90 && !badges.contains("Productivity Expert")) {
      badges.add("Productivity Expert");
      badgesUpdated = true;
    }

    Map<String, dynamic> updateData = {
      "productivityScore": score,
    };

    if (badgesUpdated) {
      updateData["badges"] = badges;
    }

    await docRef.update(updateData);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> analytics(String uid) {
    return _firestore.collection("users").doc(uid).snapshots();
  }

  // ===========================================================
  // REWARDS SYSTEM
  // ===========================================================

  Future<void> rewardTaskCompletion(String uid) async {
    final docRef = _firestore.collection("users").doc(uid);

    final doc = await docRef.get();

    if (!doc.exists) return;

    final data = doc.data()!;

    int rewardPoints = data["rewardPoints"] ?? 0;
    int xp = data["xp"] ?? 0;
    int completedTasks = data["completedTasks"] ?? 0;
    int streak = data["streak"] ?? 0;

    List badges = List.from(data["badges"] ?? []);

    rewardPoints += 10;
    xp += 10;
    completedTasks += 1;
    streak += 1;

    int level = (xp ~/ 100) + 1;

    if (completedTasks >= 1 && !badges.contains("First Step")) {
      badges.add("First Step");
    }

    if (completedTasks >= 5 && !badges.contains("Task Master")) {
      badges.add("Task Master");
    }

    if (completedTasks >= 10 && !badges.contains("Task Champion")) {
      badges.add("Task Champion");
    }

    if (rewardPoints >= 100 && !badges.contains("Reward Collector")) {
      badges.add("Reward Collector");
    }

    await docRef.update({
      "rewardPoints": rewardPoints,
      "xp": xp,
      "level": level,
      "completedTasks": completedTasks,
      "streak": streak,
      "badges": badges,
    });
  }
}