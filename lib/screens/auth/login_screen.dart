import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  bool obscurePassword = true;
  bool loading = false;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      await AuthService.instance.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.track_changes,
                    size: 90,
                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Welcome Back",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Sign in to continue using FocusFlow",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 36),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon:
                      const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                            !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 12),
                        child: Text(
                          "OR",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const SignupScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add_alt_1,
                    ),
                    label: const Text(
                      "Create New Account",
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        55,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      "FocusFlow v1.0",
                      style: theme.textTheme.bodySmall,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "Stay Organized • Stay Productive",
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}