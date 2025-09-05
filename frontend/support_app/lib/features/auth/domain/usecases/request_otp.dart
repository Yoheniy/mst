import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/core/usecases/usecase.dart';
import 'package:support_app/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class RequestOtp implements UseCase<void, RequestOtpParams> {
  final AuthRepository repository;

  RequestOtp(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestOtpParams params) {
    return repository.requestOtp(params.email);
  }
}

class RequestOtpParams extends Equatable {
  final String email;

  const RequestOtpParams(this.email);

  @override
  List<Object> get props => [email];
}