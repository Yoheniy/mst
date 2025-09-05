import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:support_app/features/auth/data/models/user_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<UserModel> login(String email, String password) async {
    print('🔵 LOGIN REQUEST:');
    print('  URL: /login');
    print('  Email: $email');
    print('  Password: [HIDDEN]');

    try {
      final response = await dio.post(
        '/login',
        data: FormData.fromMap({'username': email, 'password': password}),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      print('🔵 LOGIN RESPONSE:');
      print('  Status Code: ${response.statusCode}');
      print('  Response Headers: ${response.headers}');
      print('  Response Data: ${response.data}');

      // Check if login was successful and extract user data
      if (response.statusCode == 200) {
        print('✅ Login successful');
        // The backend returns user data in a 'user' field
        return UserModel.fromJson(response.data['user']);
      } else {
        print('❌ Login failed with status: ${response.statusCode}');
        print('❌ Error response: ${response.data}');
        throw Exception(
            'Login failed: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ LOGIN EXCEPTION: $e');

      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        print(
            '📋 Login Error Response: ${e.response!.statusCode} - $errorData');

        // Parse specific error messages
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('detail')) {
          final detail = errorData['detail'];
          if (detail is String) {
            throw Exception(detail);
          } else if (detail is Map<String, dynamic> &&
              detail.containsKey('message')) {
            throw Exception(detail['message'] as String);
          }
        }

        // Fallback to generic error message
        throw Exception('Login failed: ${errorData.toString()}');
      }

      throw Exception('Login failed: ${e.message ?? 'Network error'}');
    } catch (e) {
      print('❌ LOGIN GENERAL ERROR: $e');
      rethrow;
    }
  }

  /// Get the raw login response data (including access_token)
  Future<Map<String, dynamic>> getLoginResponseData(
      String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: FormData.fromMap({'username': email, 'password': password}),
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting login response data: $e');
      rethrow;
    }
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    print('🔵 REGISTRATION REQUEST:');
    print('  URL: /register/');
    print('  Data: $data');

    try {
      final response = await dio.post('/register/', data: data);

      print('🔵 REGISTRATION RESPONSE:');
      print('  Status Code: ${response.statusCode}');
      print('  Response Headers: ${response.headers}');
      print('  Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registration successful, proceeding to login...');
        // After successful registration, login the user
        return await login(data['email'], data['password']);
      } else {
        print('❌ Registration failed with status: ${response.statusCode}');
        print('❌ Error response: ${response.data}');
        throw Exception(
            'Registration failed: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ REGISTRATION EXCEPTION: $e');

      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        print('📋 Error Response: ${e.response!.statusCode} - $errorData');

        // Parse specific validation errors
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('detail')) {
          final detail = errorData['detail'];

          if (detail is Map<String, dynamic> && detail.containsKey('message')) {
            String errorMessage = detail['message'] as String;

            // If there are password requirements, format them nicely
            if (detail.containsKey('requirements') &&
                detail.containsKey('missing')) {
              final missing = detail['missing'] as List;

              List<String> missingReqs = [];
              for (String req in missing) {
                switch (req) {
                  case 'length':
                    missingReqs.add('At least 8 characters');
                    break;
                  case 'lowercase':
                    missingReqs.add('At least one lowercase letter');
                    break;
                  case 'uppercase':
                    missingReqs.add('At least one uppercase letter');
                    break;
                  case 'digit':
                    missingReqs.add('At least one number');
                    break;
                  case 'special':
                    missingReqs.add('At least one special character');
                    break;
                }
              }

              if (missingReqs.isNotEmpty) {
                errorMessage =
                    'Password requirements:\n• ${missingReqs.join('\n• ')}';
              }
            }

            throw Exception(errorMessage);
          } else if (detail is String) {
            throw Exception(detail);
          }
        }

        // Fallback to generic error message
        throw Exception('Registration failed: ${errorData.toString()}');
      }

      throw Exception('Registration failed: ${e.message ?? 'Network error'}');
    } catch (e) {
      print('❌ REGISTRATION GENERAL ERROR: $e');
      rethrow;
    }
  }

  Future<void> requestOtp(String email) async {
    print('🔵 OTP REQUEST:');
    print('  URL: /reset-password');
    print('  Email: $email');

    try {
      final response = await dio.post('/reset-password?email=$email');
      print('✅ OTP Request successful!');
      print('  Status Code: ${response.statusCode}');
      print('  Response Headers: ${response.headers}');
      print('  Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to request OTP: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ OTP Request DioException:');
      print('  Error Type: ${e.type}');
      print('  Message: ${e.message}');
      if (e.response != null) {
        print('  Status Code: ${e.response?.statusCode}');
        print('  Response Data: ${e.response?.data}');
      }
      throw Exception('Failed to request OTP: ${e.message}');
    } catch (e) {
      print('❌ OTP Request General Error: $e');
      throw Exception('Failed to request OTP: $e');
    }
  }

  Future<void> changePassword(
      String email, String otp, String newPassword) async {
    print('🔵 CHANGE PASSWORD REQUEST:');
    print('  URL: /change-password-public');
    print('  Email: $email');
    print('  OTP: $otp');
    print('  New Password: [HIDDEN]');

    try {
      final response = await dio.post(
          '/change-password-public?email=$email&otp=$otp&new_password=$newPassword');
      print('✅ Change Password successful!');
      print('  Status Code: ${response.statusCode}');
      print('  Response Headers: ${response.headers}');
      print('  Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to change password: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ Change Password DioException:');
      print('  Error Type: ${e.type}');
      print('  Message: ${e.message}');
      if (e.response != null) {
        print('  Status Code: ${e.response?.statusCode}');
        print('  Response Data: ${e.response?.data}');
      }
      throw Exception('Failed to change password: ${e.message}');
    } catch (e) {
      print('❌ Change Password General Error: $e');
      throw Exception('Failed to change password: $e');
    }
  }
}
