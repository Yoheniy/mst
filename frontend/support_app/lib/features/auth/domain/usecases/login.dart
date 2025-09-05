import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/core/usecases/usecase.dart';
import 'package:support_app/features/auth/domain/entities/user.dart';
import 'package:support_app/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class Login implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  Login(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}