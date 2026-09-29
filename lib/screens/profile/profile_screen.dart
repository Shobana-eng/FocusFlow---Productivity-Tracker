import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = auth.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    final String displayName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!
        : "FocusFlow User";
    final String email = user.email ?? "No Email";
    final String initials = displayName.trim().split(" ").where((e) => e.isNotEmpty).take(2).map((e) => e[0].toUpperCase()).join();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection("users").doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          int level = 1;
          int xp = 0;
          List badges = [];
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!;
            level = data.get("level") ?? 1;
            xp = data.get("xp") ?? 0;
            badges = List.from(data.get("badges") ?? []);
          }

          return CustomScrollView(
            slivers: [
              // Modern Gradient Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white24,
                          child: Text(initials, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        const SizedBox(height: 15),
                        Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(email, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                          child: Text("Level $level • $xp XP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Gallery Preview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Achievements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("${badges.length}/6 Unlocked", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _miniBadge("First Step", Icons.emoji_events, Colors.orange, badges.contains("First Step")),
                            _miniBadge("Task Master", Icons.workspace_premium, Colors.green, badges.contains("Task Master")),
                            _miniBadge("Task Champion", Icons.military_tech, Colors.blue, badges.contains("Task Champion")),
                            _miniBadge("Reward Collector", Icons.stars, Colors.amber, badges.contains("Reward Collector")),
                            _miniBadge("Productivity Pro", Icons.auto_graph, Colors.purple, badges.contains("Productivity Pro")),
                            _miniBadge("Productivity Expert", Icons.star, Colors.red, badges.contains("Productivity Expert")),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),
                      const Text("General", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      _actionTile(Icons.person_outline, "Edit Profile", "Update your basic details", Colors.blue, () => _showEditProfileDialog()),
                      _actionTile(Icons.lock_reset, "Change Password", "Get a reset link in your mail", Colors.orange, () async {
                        if (user.email != null) {
                          await auth.sendPasswordResetEmail(email: user.email!);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset link sent!")));
                        }
                      }),
                      _actionTile(Icons.logout, "Logout", "Sign out of FocusFlow", Colors.redAccent, () async {
                        await auth.signOut();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _miniBadge(String name, IconData icon, Color color, bool unlocked) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: unlocked ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
            child: Icon(icon, color: unlocked ? color : Colors.grey.withOpacity(0.4), size: 24),
          ),
          const SizedBox(height: 8),
          Text(name, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: unlocked ? null : Colors.grey, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 22)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Future<void> _showEditProfileDialog() async {
    final user = auth.currentUser;
    final TextEditingController nameController = TextEditingController(text: user?.displayName ?? "");
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: "Display Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () async {
            if (nameController.text.trim().isNotEmpty) {
              await user?.updateDisplayName(nameController.text.trim());
              await user?.reload();
              if (mounted) setState(() {});
              Navigator.pop(context);
            }
          }, child: const Text("Save")),
        ],
      ),
    );
  }
}
