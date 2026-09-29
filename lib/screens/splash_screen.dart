import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff09090F),
              Color(0xff10152A),
              Color(0xff191B36),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Curves.easeOutBack,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [

                Icon(
                  Icons.auto_awesome,
                  size: 90,
                  color: Colors.deepPurpleAccent,
                ),

                SizedBox(height: 25),

                Text(
                  "FocusFlow",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  "AI-Powered Student Productivity Tracker",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}