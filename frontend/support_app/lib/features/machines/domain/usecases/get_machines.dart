import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/core/usecases/usecase.dart';
import '../entities/machine.dart';
import '../repositories/machine_repository.dart';

class GetMachines implements UseCase<List<Machine>, NoParams> {
  final MachineRepository repository;

  GetMachines(this.repository);

  @override
  Future<Either<Failure, List<Machine>>> call(NoParams params) async {
    return await repository.getMachines();
  }
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
