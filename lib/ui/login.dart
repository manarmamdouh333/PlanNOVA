// lib/features/auth/screens/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plannova/controllers/auth_contrller.dart';
import 'package:plannova/core/colors.dart';
import 'package:plannova/ui/FreeHours.dart';
import 'package:plannova/ui/HomeOverviewScreen.dart';
import 'package:plannova/ui/Home_Screen.dart';
import 'package:plannova/ui/Task.dart';
import 'package:plannova/ui/register.dart';
import 'package:plannova/ui/setupScreen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
  body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            Color(0xFF2C4356),
                          Color(0xFF14B8A6),
            ],
          ),),child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [   Color(0xFF2C4356),
                          Color(0xFF14B8A6),],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          "Plannova",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "Smart Weekly Planning",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C4356),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sign in to continue",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty ? "Enter email" : null,
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        obscureText: true,
                        validator: (value) => value!.length < 6 ? "Password too short" : null,
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: authController.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final success = await authController.login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                    );
                                  // داخل دالة الـ login بعد النجاح
if (success && mounted) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final data = userDoc.data() ?? {};

  final profile = data['profile'] as Map<String, dynamic>?;
  final freeHours = data['freeHours'] as Map<String, dynamic>?;

  bool setupCompleted =
      profile != null && profile['setupCompleted'] == true;

  bool freeHoursCompleted =
      freeHours != null && freeHours.isNotEmpty;

  if (!setupCompleted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SetupScreen()),
    );
  } 
  else if (!freeHoursCompleted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FreeHoursScreen()),
    );
  } 
else {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => HomeOverviewScreen(),
    ),
  );
}
}
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:AppColors.lightPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: authController.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Login",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                      ),

                      if (authController.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            authController.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?",style: TextStyle(fontSize: 20),),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: const Text("Register",
                                style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.lightPrimary)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),),
          ),
        ),
      ),
    );
  }
}