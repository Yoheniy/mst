import 'package:dartz/dartz.dart';
import 'package:support_app/core/errors/failures.dart';
import '../entities/machine.dart';

abstract class MachineRepository {
  /// Get all machines for the current user
  Future<Either<Failure, List<Machine>>> getMachines();

  /// Get a specific machine by ID
  Future<Either<Failure, Machine>> getMachine(int id);

  /// Create a new machine
  Future<Either<Failure, Machine>> createMachine(Machine machine);

  /// Update an existing machine
  Future<Either<Failure, Machine>> updateMachine(Machine machine);

  /// Delete a machine
  Future<Either<Failure, bool>> deleteMachine(int id);

  /// Get machines by status
  Future<Either<Failure, List<Machine>>> getMachinesByStatus(String status);

  /// Get machines by type
  Future<Either<Failure, List<Machine>>> getMachinesByType(String type);

  /// Search machines by name or model
  Future<Either<Failure, List<Machine>>> searchMachines(String query);

  /// Update machine status
  Future<Either<Failure, Machine>> updateMachineStatus(int id, String status);

  /// Schedule maintenance for a machine
  Future<Either<Failure, Machine>> scheduleMaintenance(int id, DateTime date);

  /// Get machines that need maintenance
  Future<Either<Failure, List<Machine>>> getMachinesNeedingMaintenance();
}
