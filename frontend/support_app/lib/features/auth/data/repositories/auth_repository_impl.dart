import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:support_app/features/auth/domain/entities/user.dart';
import 'package:support_app/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences localStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.localStorage);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);

      // Extract the real JWT token from the response
      final response =
          await remoteDataSource.getLoginResponseData(email, password);
      print('🔍 Auth - Login response keys: ${response.keys.toList()}');

      if (response.containsKey('access_token')) {
        final token = response['access_token'] as String;
        final refreshToken = response['refresh_token'] as String?;

        print('🔍 Auth - About to store token: ${token.substring(0, 20)}...');
        await localStorage.setString('access_token', token);
        if (refreshToken != null) {
          await localStorage.setString('refresh_token', refreshToken);
        }

        // Store token timestamp for expiration checking
        await localStorage.setInt(
            'token_timestamp', DateTime.now().millisecondsSinceEpoch);

        // Verify token was stored
        final storedToken = localStorage.getString('access_token');
        print(
            '🔍 Auth - Stored token verification: ${storedToken?.substring(0, 20) ?? 'NULL'}...');

        return Right(userModel);
      } else {
        print('❌ No access_token found in login response');
        throw Exception('No access token received from server');
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(String email, String fullName,
      String password, String serialNumber) async {
    try {
      final data = {
        'email': email,
        'full_name': fullName,
        'password': password,
        'machine_serial_number': serialNumber,
      };
      final userModel = await remoteDataSource.register(data);

      // After successful registration, get the login response to extract token
      try {
        final response =
            await remoteDataSource.getLoginResponseData(email, password);
        if (response.containsKey('access_token')) {
          final token = response['access_token'] as String;
          final refreshToken = response['refresh_token'] as String?;

          await localStorage.setString('access_token', token);
          if (refreshToken != null) {
            await localStorage.setString('refresh_token', refreshToken);
          }
          // Store token timestamp for expiration checking
          await localStorage.setInt(
              'token_timestamp', DateTime.now().millisecondsSinceEpoch);
          print(
              '✅ JWT token stored after registration: ${token.substring(0, 20)}...');
        } else {
          await localStorage.setString('access_token', 'dummy_token');
        }
      } catch (e) {
        print('⚠️ Could not get token after registration: $e');
        await localStorage.setString('access_token', 'dummy_token');
      }

      return Right(userModel);
    } catch (e) {
      print('Registration error: $e'); // Debug logging
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestOtp(String email) async {
    try {
      await remoteDataSource.requestOtp(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
      String email, String otp, String newPassword) async {
    try {
      await remoteDataSource.changePassword(email, otp, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
