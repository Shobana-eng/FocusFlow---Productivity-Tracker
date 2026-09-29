import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_provider.dart';
import '../../themes/app_theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FocusFlow Settings",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Customize your productivity experience.",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _settingTile(
              context,
              Icons.person_outline,
              "Account",
              onTap: () {},
            ),
            _settingTile(
              context,
              Icons.notifications_outlined,
              "Notifications",
              onTap: () {},
            ),
            _settingTile(
              context,
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              "Dark Mode",
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
              onTap: () {
                themeProvider.toggleTheme();
              },
            ),
            _settingTile(
              context,
              Icons.lock_outline,
              "Privacy & Security",
              onTap: () {},
            ),
            _settingTile(
              context,
              Icons.language_outlined,
              "Language",
              onTap: () {},
            ),
            _settingTile(
              context,
              Icons.help_outline,
              "Help & Support",
              onTap: () {},
            ),
            _settingTile(
              context,
              Icons.info_outline,
              "About FocusFlow",
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "FocusFlow",
                  applicationVersion: "1.0.0",
                );
              },
            ),
            _settingTile(
              context,
              Icons.logout,
              "Logout",
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(.15),
          child: Icon(
            icon,
            color: AppTheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: trailing ??
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 18,
            ),
        onTap: onTap,
      ),
    );
  }
}
