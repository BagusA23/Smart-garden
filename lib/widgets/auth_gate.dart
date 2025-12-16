// lib/presentation/widgets/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../pages/login_page.dart';
import '../pages/verify_email_page.dart';
import '../../routes/BottomNavBar.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User login
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // Email sudah diverifikasi
          if (user.emailVerified) {
            return const BottomNavBar(); // ⬅️ PENTING
          }

          // Email belum diverifikasi
          return const VerifyEmailPage();
        }

        // Belum login
        return const LoginPage();
      },
    );
  }
}
