import 'package:dartz/dartz.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
      String email, String fullName, String password, String serialNumber);
  Future<Either<Failure, void>> requestOtp(String email); // NEW
  Future<Either<Failure, void>> changePassword(
      String email, String otp, String newPassword); // NEW
}
