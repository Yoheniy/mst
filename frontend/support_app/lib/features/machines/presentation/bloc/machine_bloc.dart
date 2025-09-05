import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:support_app/features/machines/domain/entities/machine.dart';
import 'package:support_app/features/machines/domain/usecases/get_machines.dart';
import 'package:support_app/features/machines/domain/usecases/create_machine.dart';

// Events
abstract class MachineEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMachines extends MachineEvent {}

class CreateMachineEvent extends MachineEvent {
  final Machine machine;

  CreateMachineEvent(this.machine);

  @override
  List<Object> get props => [machine];
}

class UpdateMachineEvent extends MachineEvent {
  final Machine machine;

  UpdateMachineEvent(this.machine);

  @override
  List<Object> get props => [machine];
}

class DeleteMachineEvent extends MachineEvent {
  final int machineId;

  DeleteMachineEvent(this.machineId);

  @override
  List<Object> get props => [machineId];
}

class SearchMachinesEvent extends MachineEvent {
  final String query;

  SearchMachinesEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FilterMachinesByStatusEvent extends MachineEvent {
  final String status;

  FilterMachinesByStatusEvent(this.status);

  @override
  List<Object> get props => [status];
}

class FilterMachinesByTypeEvent extends MachineEvent {
  final String type;

  FilterMachinesByTypeEvent(this.type);

  @override
  List<Object> get props => [type];
}

// States
abstract class MachineState extends Equatable {
  @override
  List<Object> get props => [];
}

class MachineInitial extends MachineState {}

class MachineLoading extends MachineState {}

class MachinesLoaded extends MachineState {
  final List<Machine> machines;
  final List<Machine> filteredMachines;
  final String? searchQuery;
  final String? statusFilter;
  final String? typeFilter;

  MachinesLoaded({
    required this.machines,
    required this.filteredMachines,
    this.searchQuery,
    this.statusFilter,
    this.typeFilter,
  });

  @override
  List<Object> get props => [
        machines,
        filteredMachines,
        searchQuery ?? '',
        statusFilter ?? '',
        typeFilter ?? ''
      ];

  MachinesLoaded copyWith({
    List<Machine>? machines,
    List<Machine>? filteredMachines,
    String? searchQuery,
    String? statusFilter,
    String? typeFilter,
  }) {
    return MachinesLoaded(
      machines: machines ?? this.machines,
      filteredMachines: filteredMachines ?? this.filteredMachines,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}

class MachineCreated extends MachineState {
  final Machine machine;

  MachineCreated(this.machine);

  @override
  List<Object> get props => [machine];
}

class MachineUpdated extends MachineState {
  final Machine machine;

  MachineUpdated(this.machine);

  @override
  List<Object> get props => [machine];
}

class MachineDeleted extends MachineState {
  final int machineId;

  MachineDeleted(this.machineId);

  @override
  List<Object> get props => [machineId];
}

class MachineError extends MachineState {
  final String message;

  MachineError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class MachineBloc extends Bloc<MachineEvent, MachineState> {
  final GetMachines getMachines;
  final CreateMachine createMachine;

  MachineBloc({
    required this.getMachines,
    required this.createMachine,
  }) : super(MachineInitial()) {
    on<LoadMachines>(_onLoadMachines);
    on<CreateMachineEvent>(_onCreateMachine);
    on<SearchMachinesEvent>(_onSearchMachines);
    on<FilterMachinesByStatusEvent>(_onFilterByStatus);
    on<FilterMachinesByTypeEvent>(_onFilterByType);
  }

  Future<void> _onLoadMachines(
      LoadMachines event, Emitter<MachineState> emit) async {
    emit(MachineLoading());

    final result = await getMachines(NoParams());

    result.fold(
      (failure) => emit(MachineError(failure.toString())),
      (machines) => emit(MachinesLoaded(
        machines: machines,
        filteredMachines: machines,
      )),
    );
  }

  Future<void> _onCreateMachine(
      CreateMachineEvent event, Emitter<MachineState> emit) async {
    emit(MachineLoading());

    final result = await createMachine(CreateMachineParams(event.machine));

    result.fold(
      (failure) => emit(MachineError(failure.toString())),
      (machine) => emit(MachineCreated(machine)),
    );
  }

  void _onSearchMachines(
      SearchMachinesEvent event, Emitter<MachineState> emit) {
    if (state is MachinesLoaded) {
      final currentState = state as MachinesLoaded;
      final filteredMachines = currentState.machines.where((machine) {
        final query = event.query.toLowerCase();
        return machine.name.toLowerCase().contains(query) ||
            machine.model.toLowerCase().contains(query) ||
            machine.manufacturer.toLowerCase().contains(query) ||
            machine.serialNumber.toLowerCase().contains(query);
      }).toList();

      emit(currentState.copyWith(
        filteredMachines: filteredMachines,
        searchQuery: event.query,
      ));
    }
  }

  void _onFilterByStatus(
      FilterMachinesByStatusEvent event, Emitter<MachineState> emit) {
    if (state is MachinesLoaded) {
      final currentState = state as MachinesLoaded;
      final filteredMachines = currentState.machines.where((machine) {
        return machine.status.name == event.status;
      }).toList();

      emit(currentState.copyWith(
        filteredMachines: filteredMachines,
        statusFilter: event.status,
      ));
    }
  }

  void _onFilterByType(
      FilterMachinesByTypeEvent event, Emitter<MachineState> emit) {
    if (state is MachinesLoaded) {
      final currentState = state as MachinesLoaded;
      final filteredMachines = currentState.machines.where((machine) {
        return machine.type.name == event.type;
      }).toList();

      emit(currentState.copyWith(
        filteredMachines: filteredMachines,
        typeFilter: event.type,
      ));
    }
  }
}
