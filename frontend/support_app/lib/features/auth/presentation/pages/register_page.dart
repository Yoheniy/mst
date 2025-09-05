import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:support_app/utils/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _serialNumberController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _serialNumberController.dispose();
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
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 96, 203, 96),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          context.go('/login');
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 74, 198, 74),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'machine support',
                            style: const TextStyle(
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
                const SizedBox(height: 20),

                // Main Content
                Expanded(
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registration successful!')),
                        );
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
                            duration: const Duration(seconds: 5),
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

                            // Title Section
                            Text(
                              'Create Account',
                              style: AppTheme.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Create your account for daily updates.',
                              style: AppTheme.poppins(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Full Name Field
                                  Text(
                                    'Full Name',
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
                                      border:
                                          Border.all(color: Colors.grey[700]!),
                                    ),
                                    child: TextField(
                                      controller: _fullNameController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your full name',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        prefixIcon: const Icon(
                                            Icons.person_outline,
                                            color: Colors.white),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 18),
                                      ),
                                      style: AppTheme.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

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
                                      border:
                                          Border.all(color: Colors.grey[700]!),
                                    ),
                                    child: TextField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: Colors.white),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                      border:
                                          Border.all(color: Colors.grey[700]!),
                                    ),
                                    child: TextField(
                                      controller: _passwordController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your Password',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        prefixIcon: const Icon(
                                            Icons.lock_outline,
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 18),
                                      ),
                                      obscureText: !_isPasswordVisible,
                                      style: AppTheme.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Password Requirements Hint
                                  Text(
                                    'Password must contain: 8+ characters, lowercase, uppercase, number',
                                    style: AppTheme.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Confirm Password Field
                                  Text(
                                    'Confirm Password',
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
                                      border:
                                          Border.all(color: Colors.grey[700]!),
                                    ),
                                    child: TextField(
                                      controller: _confirmPasswordController,
                                      decoration: InputDecoration(
                                        hintText: 'Confirm your Password',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: Colors.white),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isConfirmPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey[400],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isConfirmPasswordVisible =
                                                  !_isConfirmPasswordVisible;
                                            });
                                          },
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 18),
                                      ),
                                      obscureText: !_isConfirmPasswordVisible,
                                      style: AppTheme.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Machine Serial Number Field
                                  Text(
                                    'Machine Serial Number',
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
                                      border:
                                          Border.all(color: Colors.grey[700]!),
                                    ),
                                    child: TextField(
                                      controller: _serialNumberController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter machine serial number',
                                        hintStyle:
                                            TextStyle(color: Colors.grey[500]),
                                        prefixIcon: const Icon(
                                            Icons.build_outlined,
                                            color: Colors.white),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 18),
                                      ),
                                      style: AppTheme.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Create Account Button
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
                                          color: const Color(0xFF4CAF50)
                                              .withAlpha(80),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: isLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                context.read<AuthBloc>().add(
                                                      RegisterEvent(
                                                        _emailController.text,
                                                        _fullNameController
                                                            .text,
                                                        _passwordController
                                                            .text,
                                                        _serialNumberController
                                                            .text,
                                                      ),
                                                    );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2)
                                          : Text(
                                              'Create Account',
                                              style: AppTheme.poppins(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Login Link
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Already have an account? ',
                                          style: AppTheme.poppins(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'login',
                                              style: AppTheme.poppins(
                                                color:
                                                    AppTheme.accentGreenPrimary,
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
