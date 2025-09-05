import 'package:dartz/dartz.dart';
import 'package:support_app/core/errors/failures.dart';
import '../../domain/entities/machine.dart';
import '../../domain/repositories/machine_repository.dart';

class MachineRepositoryImpl implements MachineRepository {
  // Mock data for development
  final List<Machine> _mockMachines = [
    Machine(
      id: 1,
      name: 'CNC Lathe Alpha',
      model: 'TL-2000',
      serialNumber: 'CNC001-2024',
      manufacturer: 'Haas Automation',
      type: MachineType.lathe,
      status: MachineStatus.operational,
      description: 'High-precision CNC lathe for complex turning operations',
      installationDate: DateTime(2024, 1, 15),
      lastMaintenanceDate: DateTime(2024, 8, 1),
      nextMaintenanceDate: DateTime(2024, 11, 1),
      location: 'Production Line A',
      operator: 'John Smith',
      specifications: {
        'max_diameter': '400mm',
        'max_length': '1000mm',
        'spindle_speed': '4000 RPM',
        'power': '15 kW',
      },
      capabilities: ['Turning', 'Facing', 'Threading', 'Drilling'],
      manualUrl: 'https://example.com/manuals/tl-2000.pdf',
      imageUrl: 'https://example.com/images/cnc-lathe.jpg',
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 9, 4),
    ),
    Machine(
      id: 2,
      name: 'Vertical Mill Bravo',
      model: 'VM-3',
      serialNumber: 'VM002-2024',
      manufacturer: 'Haas Automation',
      type: MachineType.mill,
      status: MachineStatus.maintenance,
      description: '3-axis vertical milling machine for precision machining',
      installationDate: DateTime(2024, 2, 10),
      lastMaintenanceDate: DateTime(2024, 7, 15),
      nextMaintenanceDate: DateTime(2024, 9, 15),
      location: 'Production Line B',
      operator: 'Sarah Johnson',
      specifications: {
        'table_size': '406 x 305 mm',
        'travel_x': '406 mm',
        'travel_y': '305 mm',
        'travel_z': '406 mm',
        'spindle_speed': '8100 RPM',
        'power': '20 kW',
      },
      capabilities: ['Milling', 'Drilling', 'Tapping', 'Boring'],
      manualUrl: 'https://example.com/manuals/vm-3.pdf',
      imageUrl: 'https://example.com/images/vertical-mill.jpg',
      createdAt: DateTime(2024, 2, 10),
      updatedAt: DateTime(2024, 9, 4),
    ),
    Machine(
      id: 3,
      name: 'Surface Grinder Charlie',
      model: 'SG-510',
      serialNumber: 'SG003-2023',
      manufacturer: 'Chevalier Machinery',
      type: MachineType.grinder,
      status: MachineStatus.operational,
      description: 'Precision surface grinder for fine finishing operations',
      installationDate: DateTime(2023, 11, 20),
      lastMaintenanceDate: DateTime(2024, 6, 10),
      nextMaintenanceDate: DateTime(2024, 12, 10),
      location: 'Finishing Department',
      operator: 'Mike Davis',
      specifications: {
        'table_size': '510 x 200 mm',
        'max_grinding_height': '400 mm',
        'wheel_diameter': '200 mm',
        'wheel_width': '25 mm',
        'power': '3 kW',
      },
      capabilities: [
        'Surface Grinding',
        'Precision Finishing',
        'Flatness Control'
      ],
      manualUrl: 'https://example.com/manuals/sg-510.pdf',
      imageUrl: 'https://example.com/images/surface-grinder.jpg',
      createdAt: DateTime(2023, 11, 20),
      updatedAt: DateTime(2024, 9, 4),
    ),
    Machine(
      id: 4,
      name: 'Drill Press Delta',
      model: 'DP-16',
      serialNumber: 'DP004-2023',
      manufacturer: 'Jet Tools',
      type: MachineType.drill,
      status: MachineStatus.error,
      description: 'Heavy-duty drill press for production drilling operations',
      installationDate: DateTime(2023, 9, 5),
      lastMaintenanceDate: DateTime(2024, 5, 20),
      nextMaintenanceDate: DateTime(2024, 11, 20),
      location: 'Assembly Area',
      operator: 'Lisa Chen',
      specifications: {
        'max_drill_size': '16mm',
        'spindle_travel': '127 mm',
        'table_size': '305 x 305 mm',
        'spindle_speed': '500-3000 RPM',
        'power': '1.5 kW',
      },
      capabilities: ['Drilling', 'Reaming', 'Counterboring', 'Tapping'],
      manualUrl: 'https://example.com/manuals/dp-16.pdf',
      imageUrl: 'https://example.com/images/drill-press.jpg',
      createdAt: DateTime(2023, 9, 5),
      updatedAt: DateTime(2024, 9, 4),
    ),
  ];

  @override
  Future<Either<Failure, List<Machine>>> getMachines() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return Right(_mockMachines);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Machine>> getMachine(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final machine = _mockMachines.firstWhere((m) => m.id == id);
      return Right(machine);
    } catch (e) {
      return Left(ServerFailure('Machine not found'));
    }
  }

  @override
  Future<Either<Failure, Machine>> createMachine(Machine machine) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      // Simulate creating a new machine with a new ID
      final newMachine = machine.copyWith(
        id: _mockMachines.length + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _mockMachines.add(newMachine);
      return Right(newMachine);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Machine>> updateMachine(Machine machine) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final index = _mockMachines.indexWhere((m) => m.id == machine.id);
      if (index != -1) {
        final updatedMachine = machine.copyWith(updatedAt: DateTime.now());
        _mockMachines[index] = updatedMachine;
        return Right(updatedMachine);
      }
      return Left(ServerFailure('Machine not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMachine(int id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final index = _mockMachines.indexWhere((m) => m.id == id);
      if (index != -1) {
        _mockMachines.removeAt(index);
        return const Right(true);
      }
      return Left(ServerFailure('Machine not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Machine>>> getMachinesByStatus(
      String status) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final machines =
          _mockMachines.where((m) => m.status.name == status).toList();
      return Right(machines);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Machine>>> getMachinesByType(String type) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final machines = _mockMachines.where((m) => m.type.name == type).toList();
      return Right(machines);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Machine>>> searchMachines(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final machines = _mockMachines.where((machine) {
        final searchQuery = query.toLowerCase();
        return machine.name.toLowerCase().contains(searchQuery) ||
            machine.model.toLowerCase().contains(searchQuery) ||
            machine.manufacturer.toLowerCase().contains(searchQuery) ||
            machine.serialNumber.toLowerCase().contains(searchQuery);
      }).toList();
      return Right(machines);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Machine>> updateMachineStatus(
      int id, String status) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockMachines.indexWhere((m) => m.id == id);
      if (index != -1) {
        final machine = _mockMachines[index];
        final newStatus =
            MachineStatus.values.firstWhere((s) => s.name == status);
        final updatedMachine = machine.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        _mockMachines[index] = updatedMachine;
        return Right(updatedMachine);
      }
      return Left(ServerFailure('Machine not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Machine>> scheduleMaintenance(
      int id, DateTime date) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockMachines.indexWhere((m) => m.id == id);
      if (index != -1) {
        final machine = _mockMachines[index];
        final updatedMachine = machine.copyWith(
          nextMaintenanceDate: date,
          updatedAt: DateTime.now(),
        );
        _mockMachines[index] = updatedMachine;
        return Right(updatedMachine);
      }
      return Left(ServerFailure('Machine not found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Machine>>> getMachinesNeedingMaintenance() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();
      final machines = _mockMachines.where((m) {
        return m.nextMaintenanceDate != null &&
            m.nextMaintenanceDate!.isBefore(now);
      }).toList();
      return Right(machines);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
