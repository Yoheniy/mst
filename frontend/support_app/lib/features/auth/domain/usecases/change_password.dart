import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/core/usecases/usecase.dart';
import 'package:support_app/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class ChangePassword implements UseCase<void, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePassword(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) {
    return repository.changePassword(
        params.email, params.otp, params.newPassword);
  }
}

class ChangePasswordParams extends Equatable {
  final String email;
  final String otp;
  final String newPassword;

  const ChangePasswordParams(this.email, this.otp, this.newPassword);

  @override
  List<Object> get props => [email, otp, newPassword];
}
