import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plannova/controllers/auth_contrller.dart';
import 'package:plannova/firebase_options.dart';
import 'package:plannova/ui/login.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: const PlanNovaApp(),
    ),
  );
}

class PlanNovaApp extends StatelessWidget {
  const PlanNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plannova',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const LoginScreen(),   // ابدأي بالـ Login
    );
  }
}