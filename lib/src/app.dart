import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class ExpoodieApp extends StatelessWidget {
  const ExpoodieApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFFFF9F4);
    const orange = Color(0xFFF26B38);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expoodie',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: orange,
          surface: background,
        ),
      ),
      home: firebaseReady
          ? const AuthGate()
          : const LoginScreen(firebaseReady: false),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == null
            ? const LoginScreen()
            : HomeScreen(user: snapshot.data!);
      },
    );
  }
}
