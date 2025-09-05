// lib/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:support_app/features/auth/presentation/pages/forget_password_page.dart';
import 'package:support_app/features/auth/presentation/pages/home_page.dart';
import 'package:support_app/features/auth/presentation/pages/login_page.dart';
import 'package:support_app/features/auth/presentation/pages/register_page.dart';
import 'package:support_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:support_app/features/splash/splash_screen.dart';
import 'package:support_app/features/onboarding/onboarding_screen.dart';
import 'package:support_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:support_app/features/chat/presentation/pages/chat_sessions_screen.dart';
import 'package:support_app/features/machines/presentation/pages/machines_page.dart';
import 'package:support_app/features/knowledge_base/presentation/pages/knowledge_base_page.dart';
import 'package:support_app/features/profile/presentation/pages/profile_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forget',
      name: 'forget',
      builder: (context, state) => const ForgetPasswordPage(),
    ),
    GoRoute(
      path: '/reset',
      name: 'reset',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/machines',
      name: 'machines',
      builder: (context, state) => const MachinesPage(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat_sessions',
      builder: (context, state) => const ChatSessionsScreen(),
    ),
    GoRoute(
      path: '/chat/:sessionId',
      name: 'chat',
      builder: (context, state) {
        final sessionId = int.parse(state.pathParameters['sessionId']!);
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?['title'] as String?;
        return ChatScreen(
          sessionId: sessionId,
          sessionTitle: title,
        );
      },
    ),
    GoRoute(
      path: '/knowledge-base',
      name: 'knowledge_base',
      builder: (context, state) => const KnowledgeBasePage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
  redirect: (context, state) {
    // Allow splash and onboarding to always be accessed without auth checks
    if (state.matchedLocation == '/splash' ||
        state.matchedLocation == '/onboarding') {
      return null;
    }

    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    // Show loading screen while checking auth status
    if (authState is AuthLoading) {
      return null;
    }

    final isAuthenticated = authState is AuthAuthenticated;
    final isAuthPage = ['/login', '/register', '/forget', '/reset']
        .contains(state.matchedLocation);

    // If not authenticated and trying to access protected routes, redirect to login
    if (!isAuthenticated && !isAuthPage) {
      return '/login';
    }

    // If authenticated and trying to access auth pages, redirect to home
    if (isAuthenticated && isAuthPage) {
      return '/home';
    }

    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found: ${state.uri}',
        style: const TextStyle(fontSize: 18),
      ),
    ),
  ),
);
