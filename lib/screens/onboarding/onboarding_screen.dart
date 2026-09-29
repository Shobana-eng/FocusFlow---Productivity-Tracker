import 'package:flutter/material.dart';
import 'package:student_productivity_tracker/screens/auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7B61FF),
                      Color(0xFF4A8BFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 70,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "FocusFlow",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "AI-Powered Student Productivity Tracker",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Boost your productivity with AI insights, smart planning, daily goals, analytics and rewards.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Get Started"),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}