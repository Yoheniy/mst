// lib/features/auth/presentation/pages/reset_password_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:support_app/utils/app_theme.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
                        color: AppTheme.accentGreenPrimary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.go('/forget'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreenPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'ai assistant',
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
                      if (state is AuthUnauthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Password reset successful! Please login.')));
                        context.go('/login');
                      }
                      if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)));
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title Section
                              Text(
                                'Reset Password',
                                style: AppTheme.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enter the OTP and your new password.',
                                style: AppTheme.poppins(
                                  fontSize: 16,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 40),

                              // OTP Field
                              Text(
                                'OTP',
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
                                  controller: _otpController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter OTP',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[500]),
                                    prefixIcon: const Icon(
                                        Icons.vpn_key_outlined,
                                        color: Colors.white),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 18),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: AppTheme.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // New Password Field
                              Text(
                                'New Password',
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
                                  controller: _newPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter new password',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[500]),
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        color: Colors.white),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isNewPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isNewPasswordVisible =
                                              !_isNewPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 18),
                                  ),
                                  obscureText: !_isNewPasswordVisible,
                                  style: AppTheme.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
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
                                  border: Border.all(color: Colors.grey[700]!),
                                ),
                                child: TextField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm new password',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[500]),
                                    prefixIcon: const Icon(Icons.lock_outline,
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 18),
                                  ),
                                  obscureText: !_isConfirmPasswordVisible,
                                  style: AppTheme.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Reset Password Button
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
                                  onPressed: isLoading ||
                                          _newPasswordController.text !=
                                              _confirmPasswordController.text
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            final email = GoRouterState.of(
                                                        context)
                                                    .uri
                                                    .queryParameters['email'] ??
                                                '';
                                            context.read<AuthBloc>().add(
                                                ChangePasswordEvent(
                                                    email,
                                                    _otpController.text,
                                                    _newPasswordController
                                                        .text));
                                          }
                                        },
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
                                          'Reset Password',
                                          style: AppTheme.poppins(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
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
