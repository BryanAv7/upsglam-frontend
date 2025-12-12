import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  /**
   * Desarrollo:
   * home: const DevHome(),
   * Produccion:
   * home: const LoginScreen(),
   */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPSGlam App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}