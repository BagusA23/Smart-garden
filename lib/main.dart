// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:smart_farming/cubit/auth/auth_cubit.dart';
import 'package:smart_farming/cubit/navigation_cubit.dart';
import 'package:smart_farming/services/auth_service.dart';
import 'package:smart_farming/pages/login_page.dart';
import 'package:smart_farming/routes/BottomNavBar.dart';
import 'package:smart_farming/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              context.read<AuthService>(),
            )..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) => NavigationCubit(),
          ),
        ],
        child: MaterialApp(
          title: 'Smart Farming',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
            ),
            useMaterial3: true,
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

// Wrapper to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Show error messages
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }
        
        // Show home if authenticated
        if (state is AuthAuthenticated) {
          return const BottomNavBar();
        }
        
        // Show login if not authenticated
        return const LoginPage();
      },
    );
  }
}