// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// // ... other imports ...
// import 'package:support_app/providers/auth_provider.dart';
// import 'package:support_app/providers/chat_provider.dart';
// import 'package:support_app/providers/machine_provider.dart';
// import 'package:support_app/screens/auth/login_screen.dart';
// import 'package:support_app/screens/auth/register_screen.dart';
// import 'package:support_app/screens/auth/set_password_screen.dart';
// import 'package:support_app/screens/home/home_screen.dart';
// import 'package:support_app/screens/machines/my_machines_screen.dart';
// import 'package:support_app/utils/app_theme.dart'; // Import your custom theme

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => MachineProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// GoRouter buildRouter(AuthProvider authProvider) {
//   return GoRouter(
//     initialLocation: authProvider.isLoading
//         ? '/loading' // Show a loading route initially
//         : (authProvider.isAuthenticated ? '/home' : '/login'),
//     routes: [
//       GoRoute(
//         path: '/loading', // NEW: Loading route
//         builder: (context, state) => const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         ),
//       ),
//       GoRoute(
//         path: '/login',
//         builder: (context, state) => const LoginScreen(),
//       ),
//       GoRoute(
//         path: '/register',
//         builder: (context, state) => const RegisterScreen(),
//       ),
//       GoRoute(
//         path: '/set-password',
//         builder: (context, state) => const SetPasswordScreen(),
//       ),
//       GoRoute(
//         path: '/home',
//         builder: (context, state) => const HomeScreen(),
//       ),
//       GoRoute(
//         path: '/my-machines',
//         builder: (context, state) => const MyMachinesScreen(),
//       ),
//       // ... Add other existing routes like /chat, /knowledge-base, etc. here
//       // For Day 5-7, focusing on auth flow.
//       GoRoute(
//         path: '/chat',
//         builder: (context, state) => const Text('Chat Screen Placeholder'),
//       ),
//       GoRoute(
//         path: '/knowledge-base',
//         builder: (context, state) => const Text('KB List Screen Placeholder'),
//         routes: [
//           GoRoute(
//             path: ':kbId',
//             builder: (context, state) => Text('KB Detail for ${state.pathParameters['kbId']} Placeholder'),
//           ),
//         ],
//       ),
//       GoRoute(
//         path: '/report-anomaly',
//         builder: (context, state) => const Text('Report Anomaly Screen Placeholder'),
//       ),
//       GoRoute(
//         path: '/media-upload',
//         builder: (context, state) => const Text('Media Upload Screen Placeholder'),
//       ),
//       GoRoute(
//         path: '/tickets',
//         builder: (context, state) => const Text('Tickets List Screen Placeholder'),
//         routes: [
//           GoRoute(
//             path: ':ticketId',
//             builder: (context, state) => Text('Ticket Detail for ${state.pathParameters['ticketId']} Placeholder'),
//           ),
//         ],
//       ),
//     ],
//     redirect: (context, state) {
//       final loggedIn = authProvider.isAuthenticated;
//       final hasPassword = authProvider.user?.hasPermanentPassword ?? false;
//       final isGoingToLogin = state.matchedLocation == '/login';
//       final isGoingToRegister = state.matchedLocation == '/register';
//       final isGoingToSetPassword = state.matchedLocation == '/set-password';
//       final isGoingToLoading = state.matchedLocation == '/loading';

//       // If auth is still loading, stay on loading route
//       if (authProvider.isLoading && !isGoingToLoading) return '/loading';
//       if (!authProvider.isLoading && isGoingToLoading) { // Once loading is done, redirect
//         return loggedIn ? '/home' : '/login';
//       }

//       // If not logged in, but trying to access any page other than login/register, redirect to login
//       if (!loggedIn && !isGoingToLogin && !isGoingToRegister) {
//         return '/login';
//       }
//       // If logged in:
//       // 1. If user doesn't have a permanent password AND is not trying to set one, redirect to set-password
//       if (loggedIn && !hasPassword && !isGoingToSetPassword) {
//         return '/set-password';
//       }
//       // 2. If logged in and has password (or is setting it), and trying to go to login/register/set-password, redirect to home
//       if (loggedIn && (hasPassword || isGoingToSetPassword) && (isGoingToLogin || isGoingToRegister || isGoingToSetPassword)) {
//         return '/home';
//       }
//       // No redirect needed
//       return null;
//     },
//     refreshListenable: authProvider,
//     errorBuilder: (context, state) => Scaffold(
//       appBar: AppBar(title: const Text('Error')),
//       body: Center(child: Text('Error: ${state.error}')),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     // Initial loading screen while AuthProvider initializes
//     if (authProvider.isLoading) {
//       return MaterialApp(
//         title: 'AI Support App',
//         theme: AppTheme.lightTheme,
//         home: const Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       );
//     }

//     return MaterialApp.router(
   
//       routerConfig: buildRouter(authProvider),
//       title: 'AI Support App',
//       theme: AppTheme.lightTheme,
//     );
//   }
// }