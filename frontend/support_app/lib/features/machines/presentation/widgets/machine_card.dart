import 'package:flutter/material.dart';
import '../../domain/entities/machine.dart';

class MachineCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback onTap;

  const MachineCard({
    super.key,
    required this.machine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          machine.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${machine.manufacturer} ${machine.model}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: machine.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: machine.statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      machine.statusDisplayName,
                      style: TextStyle(
                        color: machine.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Machine details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.tag,
                      label: 'Serial',
                      value: machine.serialNumber,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.category,
                      label: 'Type',
                      value: machine.typeDisplayName,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.location_on,
                      label: 'Location',
                      value: machine.location ?? 'Not specified',
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      icon: Icons.person,
                      label: 'Operator',
                      value: machine.operator ?? 'Not assigned',
                    ),
                  ),
                ],
              ),

              if (machine.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  machine.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Maintenance info
              if (machine.nextMaintenanceDate != null) ...[
                Row(
                  children: [
                    Icon(
                      machine.needsMaintenance ? Icons.warning : Icons.schedule,
                      size: 16,
                      color: machine.needsMaintenance
                          ? Colors.orange
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        machine.needsMaintenance
                            ? 'Maintenance overdue'
                            : 'Next maintenance: ${_formatDate(machine.nextMaintenanceDate!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: machine.needsMaintenance
                                  ? Colors.orange
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              fontWeight: machine.needsMaintenance
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to machine details
                      },
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to chat with machine context
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Support'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'In $difference days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
