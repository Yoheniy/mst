import 'package:flutter/material.dart';
import '../../domain/entities/machine.dart';

class MachineFilters extends StatefulWidget {
  final Function(String) onStatusFilter;
  final Function(String) onTypeFilter;
  final VoidCallback onClearFilters;

  const MachineFilters({
    super.key,
    required this.onStatusFilter,
    required this.onTypeFilter,
    required this.onClearFilters,
  });

  @override
  State<MachineFilters> createState() => _MachineFiltersState();
}

class _MachineFiltersState extends State<MachineFilters> {
  String? _selectedStatus;
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status Filter
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Statuses'),
              ),
              ...MachineStatus.values.map((status) => DropdownMenuItem<String>(
                    value: status.name,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_getStatusDisplayName(status)),
                      ],
                    ),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value;
              });
              if (value != null) {
                widget.onStatusFilter(value);
              } else {
                widget.onClearFilters();
              }
            },
          ),
        ),

        const SizedBox(width: 12),

        // Type Filter
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Types'),
              ),
              ...MachineType.values.map((type) => DropdownMenuItem<String>(
                    value: type.name,
                    child: Text(_getTypeDisplayName(type)),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
              if (value != null) {
                widget.onTypeFilter(value);
              } else {
                widget.onClearFilters();
              }
            },
          ),
        ),

        const SizedBox(width: 12),

        // Clear Filters Button
        IconButton(
          onPressed: () {
            setState(() {
              _selectedStatus = null;
              _selectedType = null;
            });
            widget.onClearFilters();
          },
          icon: const Icon(Icons.clear_all),
          tooltip: 'Clear all filters',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(MachineStatus status) {
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

  String _getStatusDisplayName(MachineStatus status) {
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

  String _getTypeDisplayName(MachineType type) {
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
}
