// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart';
// import 'package:support_app/utils/app_theme.dart';

// class LoginPage extends StatelessWidget {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Card(
//             elevation: 8,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             child: Padding(
//               padding: const EdgeInsets.all(32.0),
//               child: BlocConsumer<AuthBloc, AuthState>(
//                 listener: (context, state) {
//                   if (state is AuthAuthenticated) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Login successful!')));
//                     // Add a small delay to ensure state is properly updated
//                     Future.delayed(const Duration(milliseconds: 100), () {
//                       if (context.mounted) {
//                         context.go('/home');
//                       }
//                     });
//                   }
//                   if (state is AuthError) {
//                     ScaffoldMessenger.of(context)
//                         .showSnackBar(SnackBar(content: Text(state.message)));
//                   }
//                 },
//                 builder: (context, state) {
//                   final isLoading = state is AuthLoading;
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.lock, size: 80, color: AppTheme.accentColor),
//                       const SizedBox(height: 20),
//                       Text('Login',
//                           style: AppTheme.poppins(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: AppTheme.primaryColor)),
//                       const SizedBox(height: 20),
//                       TextField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           labelText: 'Email',
//                           prefixIcon: const Icon(Icons.email),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextField(
//                         controller: _passwordController,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           prefixIcon: const Icon(Icons.lock),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                         ),
//                         obscureText: true,
//                       ),
//                       const SizedBox(height: 20),
//                       if (isLoading) const CircularProgressIndicator(),
//                       ElevatedButton(
//                         onPressed: isLoading
//                             ? null
//                             : () => context.read<AuthBloc>().add(LoginEvent(
//                                 _emailController.text,
//                                 _passwordController.text)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.accentColor,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 15),
//                         ),
//                         child: const Text('Login'),
//                       ),
//                       TextButton(
//                         onPressed: () => context.go('/forget'),
//                         child: const Text('Forgot Password?'),
//                       ),
//                       TextButton(
//                         onPressed: () => context.go('/register'),
//                         child: const Text('Register'),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:support_app/utils/app_theme.dart';

class LoginPage extends StatefulWidget {
  // Changed to StatefulWidget to manage password visibility
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // NEW: State for password visibility

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2D2D2D),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 12, vertical: 6),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFF2A2A2A),
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(color: Colors.grey[700]!),
                    //   ),
                    //   child: Text(
                    //     'English',
                    //     style: AppTheme.poppins(
                    //       color: Colors.grey[400],
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    // ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 36, 217, 36),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'machine support',
                            style: AppTheme.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Main Content
                Expanded(
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login successful!')));
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            context.go('/home');
                          }
                        });
                      }
                      if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            duration: const Duration(seconds: 4),
                            backgroundColor: Colors.red[600],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Logo Section
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGreenPrimary,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentGreenPrimary
                                              .withValues(alpha: 0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.build_circle,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Machine Tool Support',
                                    style: AppTheme.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'AI-Powered Support System',
                                    style: AppTheme.poppins(
                                      fontSize: 14,
                                      color: AppTheme.accentGreenPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Welcome Section
                            Text(
                              'Welcome',
                              style: AppTheme.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Login to get machine tool support.',
                              style: AppTheme.poppins(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Email Field
                            Text(
                              'Email',
                              style: AppTheme.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[700]!),
                              ),
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      color: Colors.white),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 18),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                style: AppTheme.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            Text(
                              'Password',
                              style: AppTheme.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[700]!),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your Password',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: Colors.white),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 18),
                                ),
                                obscureText: !_isPasswordVisible,
                                style: AppTheme.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Remember Me and Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => context.go('/forget'),
                                  child: Text(
                                    'forgot Password?',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 96, 227, 151),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Login Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF66BB6A),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color(0xFF4CAF50).withAlpha(80),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => context.read<AuthBloc>().add(
                                        LoginEvent(_emailController.text,
                                            _passwordController.text)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2)
                                    : Text(
                                        'Log In',
                                        style: AppTheme.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Register Link
                            Center(
                              child: TextButton(
                                onPressed: () => context.go('/register'),
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Don\'t have an account? ',
                                    style: AppTheme.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Create an account',
                                        style: AppTheme.poppins(
                                          color: AppTheme.accentGreenPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
