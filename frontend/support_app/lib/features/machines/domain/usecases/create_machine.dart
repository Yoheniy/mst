import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:support_app/core/errors/failures.dart';
import 'package:support_app/core/usecases/usecase.dart';
import '../entities/machine.dart';
import '../repositories/machine_repository.dart';

class CreateMachine implements UseCase<Machine, CreateMachineParams> {
  final MachineRepository repository;

  CreateMachine(this.repository);

  @override
  Future<Either<Failure, Machine>> call(CreateMachineParams params) async {
    return await repository.createMachine(params.machine);
  }
}

class CreateMachineParams extends Equatable {
  final Machine machine;

  const CreateMachineParams(this.machine);

  @override
  List<Object> get props => [machine];
}
