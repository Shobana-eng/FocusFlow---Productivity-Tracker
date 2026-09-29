import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/database_service.dart';
import '../../themes/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Task Data
  int totalTasks = 0;
  int completedTasks = 0;
  int pendingTasks = 0;

  // AI Prediction State (Replacing Controllers with Sliders)
  double studyHours = 5.0;
  double sleepHours = 7.0;
  double screenTime = 3.0;

  bool predictionLoading = false;
  double? productivityScore;
  String? productivityLevel;
  List<String> recommendations = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await firestore.collection("users").doc(user.uid).collection("tasks").get();
      totalTasks = snapshot.docs.length;
      completedTasks = snapshot.docs.where((e) => e["completed"] == true).length;
      pendingTasks = totalTasks - completedTasks;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Dashboard loading error: $e");
    }
  }

  Future<void> updateTaskStatus(String taskId, bool completed) async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      await DatabaseService.instance.updateTask(uid: user.uid, taskId: taskId, completed: completed);
      loadDashboard();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to update task: $e")));
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  Future<void> getPrediction() async {
    setState(() {
      predictionLoading = true;
      productivityScore = null;
      productivityLevel = null;
      recommendations = [];
    });

    try {
      final result = await ApiService.predict(
        studyHours: studyHours,
        sleepHours: sleepHours,
        screenTime: screenTime,
      );

      if (result["success"] == true) {
        final score = (result["productivity_score"] as num).toDouble();
        final level = result["level"]?.toString() ?? "Unknown";
        final recs = List<String>.from(result["recommendations"] ?? []);

        final user = auth.currentUser;
        if (user != null) {
          await DatabaseService.instance.saveAiPrediction(
            uid: user.uid,
            score: score,
            level: level,
            studyHours: studyHours,
            sleepHours: sleepHours,
            screenTime: screenTime,
            recommendations: recs,
          );
        }

        if (!mounted) return;
        setState(() {
          productivityScore = score;
          productivityLevel = level;
          recommendations = recs;
          predictionLoading = false;
        });
      } else {
        throw Exception(result["error"] ?? "Prediction failed");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => predictionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to get prediction: $e"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Color getProductivityColor() {
    if (productivityScore == null) return AppTheme.primary;
    if (productivityScore! >= 80) return Colors.green;
    if (productivityScore! >= 60) return Colors.blue;
    if (productivityScore! >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDashboard,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(user?.displayName ?? "FocusFlow User", style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 6),
                          Text("${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.primary.withOpacity(.15),
                      child: const Icon(Icons.person, color: AppTheme.primary, size: 28),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Today's Progress Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withOpacity(.25), blurRadius: 20, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Progress", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text("${(progress * 100).round()}%",
                          style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text("$completedTasks of $totalTasks tasks completed",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // AI Prediction Section (Merged with Sliders)
                Text("AI Productivity Prediction", style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text("Adjust your daily habits to predict your performance.", style: theme.textTheme.bodyMedium),
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 15, offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(
                    children: [
                      _habitSlider("Study Hours", studyHours, 0, 12, (v) => setState(() => studyHours = v)),
                      _habitSlider("Sleep Hours", sleepHours, 0, 12, (v) => setState(() => sleepHours = v)),
                      _habitSlider("Screen Time", screenTime, 0, 16, (v) => setState(() => screenTime = v)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: predictionLoading ? null : getPrediction,
                          icon: predictionLoading
                              ? const SizedBox(
                                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.auto_awesome),
                          label: Text(predictionLoading ? "Predicting..." : "Predict Productivity"),
                        ),
                      ),
                    ],
                  ),
                ),

                // Result UI
                if (productivityScore != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: getProductivityColor().withOpacity(.10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: getProductivityColor().withOpacity(.35)),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text("AI Result", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(productivityScore!.toStringAsFixed(2),
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: getProductivityColor())),
                        const Text("Productivity Score", style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                              color: getProductivityColor().withOpacity(.15), borderRadius: BorderRadius.circular(20)),
                          child: Text(productivityLevel ?? "Unknown",
                              style: TextStyle(color: getProductivityColor(), fontWeight: FontWeight.bold)),
                        ),
                        if (recommendations.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Align(
                              alignment: Alignment.centerLeft,
                              child:
                                  Text("AI Recommendations", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                          const SizedBox(height: 12),
                          ...recommendations.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.lightbulb_outline, size: 20, color: getProductivityColor()),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(r, style: theme.textTheme.bodyMedium)),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // Overview Stats
                Text("Overview", style: theme.textTheme.titleLarge),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _StatCard(title: "Completed", value: completedTasks.toString(), icon: Icons.check_circle_outline, color: Colors.green)),
                    const SizedBox(width: 16),
                    Expanded(child: _StatCard(title: "Pending", value: pendingTasks.toString(), icon: Icons.pending_actions, color: Colors.orange)),
                  ],
                ),

                const SizedBox(height: 30),

                // Today's Tasks Stream
                Text("Today's Tasks", style: theme.textTheme.titleLarge),
                const SizedBox(height: 18),
                if (user != null)
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection("users").doc(user.uid).collection("tasks").orderBy("createdAt", descending: true).limit(5).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) return const Center(child: Text("No tasks yet"));
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final completed = data["completed"] == true;
                          return InkWell(
                            onTap: () => updateTaskStatus(docs[index].id, !completed),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 15, offset: const Offset(0, 6))],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: (completed ? Colors.green : AppTheme.primary).withOpacity(.15),
                                    child: Icon(completed ? Icons.check_circle : Icons.pending_actions, color: completed ? Colors.green : AppTheme.primary),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data["title"] ?? "", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, decoration: completed ? TextDecoration.lineThrough : TextDecoration.none)),
                                        Text(data["subject"] ?? "", style: theme.textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                  Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: completed ? Colors.green : Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _habitSlider(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value.toStringAsFixed(1), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppTheme.primary,
            inactiveColor: AppTheme.primary.withOpacity(.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 15, offset: const Offset(0, 6))]),
      child: Column(
        children: [
          CircleAvatar(radius: 24, backgroundColor: color.withOpacity(.15), child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 14),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
