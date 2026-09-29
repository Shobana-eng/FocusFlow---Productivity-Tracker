import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../themes/app_theme.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool loading = true;
  int completedTasks = 0;
  int totalTasks = 0;
  double productivityScore = 0;
  int rewardPoints = 0;
  int xp = 0;
  int level = 1;
  int streak = 0;
  List badges = [];

  @override
  void initState() {
    super.initState();
    loadRewardData();
  }

  Future<void> loadRewardData() async {
    final user = auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    try {
      final taskSnapshot = await firestore.collection("users").doc(user.uid).collection("tasks").get();
      totalTasks = taskSnapshot.docs.length;
      completedTasks = taskSnapshot.docs.where((doc) => doc["completed"] == true).length;

      final userDoc = await firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        rewardPoints = data["rewardPoints"] ?? 0;
        xp = data["xp"] ?? 0;
        level = data["level"] ?? 1;
        streak = data["streak"] ?? 0;
        badges = List.from(data["badges"] ?? []);
      }

      final predictionSnapshot = await firestore
          .collection("users")
          .doc(user.uid)
          .collection("productivity_history")
          .orderBy("createdAt", descending: true)
          .limit(1)
          .get();

      if (predictionSnapshot.docs.isNotEmpty) {
        productivityScore = (predictionSnapshot.docs.first["score"] ?? 0).toDouble();
      }

      if (mounted) setState(() => loading = false);
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    final theme = Theme.of(context);
    final xpToNextLevel = 100 - (xp % 100);
    final levelProgress = (xp % 100) / 100;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Rewards & Progress", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadRewardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Level Progress Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Level $level",
                                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                  Text(user?.displayName ?? 'Explorer', style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                              const Icon(Icons.stars, color: Colors.white, size: 40),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: levelProgress,
                              minHeight: 12,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text("$xpToNextLevel XP more to reach Level ${level + 1}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text("Your Stats", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 18),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        _buildStatCard("Total XP", xp.toString(), Icons.bolt, Colors.orange),
                        _buildStatCard("Points", rewardPoints.toString(), Icons.monetization_on, Colors.amber),
                        _buildStatCard("Streak", "$streak Days", Icons.local_fire_department, Colors.redAccent),
                        _buildStatCard("AI Score", "${productivityScore.toInt()}%", Icons.auto_graph, Colors.cyan),
                      ],
                    ),

                    const SizedBox(height: 35),

                    const Text("Achievements", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    _buildBadgeList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBadgeList() {
    final badgeData = [
      {"name": "First Step", "desc": "Complete your first task", "icon": Icons.emoji_events, "color": Colors.orange},
      {"name": "Task Master", "desc": "Complete 5 tasks", "icon": Icons.workspace_premium, "color": Colors.green},
      {"name": "Task Champion", "desc": "Complete 10 tasks", "icon": Icons.military_tech, "color": Colors.blue},
      {"name": "Reward Collector", "desc": "Earn 100 reward points", "icon": Icons.stars, "color": Colors.amber},
      {"name": "Productivity Pro", "desc": "Reach AI Score of 80%", "icon": Icons.auto_graph, "color": Colors.purple},
      {"name": "Productivity Expert", "desc": "Reach AI Score of 90%", "icon": Icons.star, "color": Colors.red},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badgeData.length,
      itemBuilder: (context, index) {
        final badge = badgeData[index];
        final isUnlocked = badges.contains(badge["name"]);
        final color = badge["color"] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isUnlocked ? color.withOpacity(0.3) : Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(badge["icon"] as IconData, color: isUnlocked ? color : Colors.grey, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(badge["name"] as String,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.white : Colors.grey)),
                    Text(badge["desc"] as String,
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Icon(isUnlocked ? Icons.check_circle : Icons.lock,
                  color: isUnlocked ? Colors.green : Colors.grey.withOpacity(0.5)),
            ],
          ),
        );
      },
    );
  }
}
