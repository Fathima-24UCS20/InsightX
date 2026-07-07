import 'package:flutter/material.dart';
import 'screens/login.dart';

void main() {
  runApp(const SalesMarketingApp());
}

class SalesMarketingApp extends StatelessWidget {
  const SalesMarketingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sales & Marketing Agent',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C4DFF)),
      ),
      home: const LoginScreen(),
    );
  }
}
