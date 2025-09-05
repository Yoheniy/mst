import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/machine_bloc.dart';
import '../widgets/machine_card.dart';
import '../widgets/machine_filters.dart';
import '../widgets/add_machine_dialog.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MachineBloc>().add(LoadMachines());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('My Machines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMachineDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search machines...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<MachineBloc>().add(LoadMachines());
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (query) {
                    if (query.isNotEmpty) {
                      context
                          .read<MachineBloc>()
                          .add(SearchMachinesEvent(query));
                    } else {
                      context.read<MachineBloc>().add(LoadMachines());
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Filters
                MachineFilters(
                  onStatusFilter: (status) {
                    context
                        .read<MachineBloc>()
                        .add(FilterMachinesByStatusEvent(status));
                  },
                  onTypeFilter: (type) {
                    context
                        .read<MachineBloc>()
                        .add(FilterMachinesByTypeEvent(type));
                  },
                  onClearFilters: () {
                    context.read<MachineBloc>().add(LoadMachines());
                  },
                ),
              ],
            ),
          ),

          // Machines List
          Expanded(
            child: BlocBuilder<MachineBloc, MachineState>(
              builder: (context, state) {
                if (state is MachineLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is MachinesLoaded) {
                  if (state.filteredMachines.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build_outlined,
                            size: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No machines found',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.searchQuery != null ||
                                    state.statusFilter != null ||
                                    state.typeFilter != null
                                ? 'Try adjusting your search or filters'
                                : 'Add your first machine to get started',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          if (state.searchQuery == null &&
                              state.statusFilter == null &&
                              state.typeFilter == null) ...[
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _showAddMachineDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Machine'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filteredMachines.length,
                    itemBuilder: (context, index) {
                      final machine = state.filteredMachines[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MachineCard(
                          machine: machine,
                          onTap: () => _showMachineDetails(context, machine),
                        ),
                      );
                    },
                  );
                } else if (state is MachineError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading machines',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MachineBloc>().add(LoadMachines());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('No machines found'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMachineDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Machine'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddMachineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMachineDialog(),
    );
  }

  void _showMachineDetails(BuildContext context, machine) {
    // TODO: Navigate to machine details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Machine details for ${machine.name} coming soon!')),
    );
  }
}
