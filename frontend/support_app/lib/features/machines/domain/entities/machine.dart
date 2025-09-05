import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MachineStatus { operational, maintenance, error, offline, calibration }

enum MachineType {
  cnc,
  lathe,
  mill,
  drill,
  grinder,
  saw,
  press,
  welder,
  laser,
  plasma,
  other
}

class Machine extends Equatable {
  final int id;
  final String name;
  final String model;
  final String serialNumber;
  final String manufacturer;
  final MachineType type;
  final MachineStatus status;
  final String? description;
  final DateTime installationDate;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final String? location;
  final String? operator;
  final Map<String, dynamic>? specifications;
  final List<String>? capabilities;
  final String? manualUrl;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Machine({
    required this.id,
    required this.name,
    required this.model,
    required this.serialNumber,
    required this.manufacturer,
    required this.type,
    required this.status,
    this.description,
    required this.installationDate,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.location,
    this.operator,
    this.specifications,
    this.capabilities,
    this.manualUrl,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        model,
        serialNumber,
        manufacturer,
        type,
        status,
        description,
        installationDate,
        lastMaintenanceDate,
        nextMaintenanceDate,
        location,
        operator,
        specifications,
        capabilities,
        manualUrl,
        imageUrl,
        createdAt,
        updatedAt,
      ];

  Machine copyWith({
    int? id,
    String? name,
    String? model,
    String? serialNumber,
    String? manufacturer,
    MachineType? type,
    MachineStatus? status,
    String? description,
    DateTime? installationDate,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    String? location,
    String? operator,
    Map<String, dynamic>? specifications,
    List<String>? capabilities,
    String? manualUrl,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Machine(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      manufacturer: manufacturer ?? this.manufacturer,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      installationDate: installationDate ?? this.installationDate,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      location: location ?? this.location,
      operator: operator ?? this.operator,
      specifications: specifications ?? this.specifications,
      capabilities: capabilities ?? this.capabilities,
      manualUrl: manualUrl ?? this.manualUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get needsMaintenance {
    if (nextMaintenanceDate == null) return false;
    return DateTime.now().isAfter(nextMaintenanceDate!);
  }

  bool get isOperational => status == MachineStatus.operational;

  bool get hasError => status == MachineStatus.error;

  bool get isOffline => status == MachineStatus.offline;

  String get statusDisplayName {
    switch (status) {
      case MachineStatus.operational:
        return 'Operational';
      case MachineStatus.maintenance:
        return 'Maintenance';
      case MachineStatus.error:
        return 'Error';
      case MachineStatus.offline:
        return 'Offline';
      case MachineStatus.calibration:
        return 'Calibration';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case MachineType.cnc:
        return 'CNC Machine';
      case MachineType.lathe:
        return 'Lathe';
      case MachineType.mill:
        return 'Mill';
      case MachineType.drill:
        return 'Drill';
      case MachineType.grinder:
        return 'Grinder';
      case MachineType.saw:
        return 'Saw';
      case MachineType.press:
        return 'Press';
      case MachineType.welder:
        return 'Welder';
      case MachineType.laser:
        return 'Laser';
      case MachineType.plasma:
        return 'Plasma';
      case MachineType.other:
        return 'Other';
    }
  }

  Color get statusColor {
    switch (status) {
      case MachineStatus.operational:
        return Colors.green;
      case MachineStatus.maintenance:
        return Colors.orange;
      case MachineStatus.error:
        return Colors.red;
      case MachineStatus.offline:
        return Colors.grey;
      case MachineStatus.calibration:
        return Colors.blue;
    }
  }
}
