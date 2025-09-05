import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/core/usecases/usecase.dart';
import 'package:support_app/features/auth/domain/entities/user.dart';
import 'package:support_app/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class Register implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(params.email, params.fullName, params.password, params.serialNumber);
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String fullName;
  final String password;
  final String serialNumber;

  const RegisterParams(this.email, this.fullName, this.password, this.serialNumber);

  @override
  List<Object> get props => [email, fullName, password, serialNumber];
}