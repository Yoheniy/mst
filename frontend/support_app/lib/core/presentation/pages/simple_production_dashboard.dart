import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/production_config.dart';
import '../../services/app_performance.dart';
import '../../services/simple_error_handler.dart';

class SimpleProductionDashboard extends StatefulWidget {
  const SimpleProductionDashboard({super.key});

  @override
  State<SimpleProductionDashboard> createState() =>
      _SimpleProductionDashboardState();
}

class _SimpleProductionDashboardState extends State<SimpleProductionDashboard> {
  late Timer _refreshTimer;
  Map<String, dynamic> _config = {};
  Map<String, dynamic> _performance = {};
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _loadData());
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _config = productionConfig.getCurrentConfig();
      _performance = appPerformance.getStats();
      _errors = errorHandler.getErrors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildConfigCard(),
            const SizedBox(height: 16),
            _buildPerformanceCard(),
            const SizedBox(height: 16),
            _buildErrorsCard(),
            const SizedBox(height: 16),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.dashboard,
          color: Theme.of(context).primaryColor,
        ),
        title: const Text('System Status'),
        subtitle: Text(
            'Configuration: ${productionConfig.isConfigurationValid() ? "Valid" : "Invalid"}'),
        trailing: Icon(
          productionConfig.isConfigurationValid()
              ? Icons.check_circle
              : Icons.error,
          color: productionConfig.isConfigurationValid()
              ? Colors.green
              : Colors.red,
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Environment: ${_config['environment'] ?? 'Unknown'}'),
            Text('API URL: ${_config['api_url'] ?? 'Unknown'}'),
            Text(
                'Timeout: ${_config['api_config']?['timeout_seconds'] ?? 'Unknown'}s'),
            Text(
                'Retries: ${_config['api_config']?['max_retries'] ?? 'Unknown'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Uptime: ${_performance['uptime_seconds'] ?? 0}s'),
            Text('Operations: ${_performance['operations']?.length ?? 0}'),
            Text('Errors: ${_performance['error_count'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Errors (${_errors.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_errors.isEmpty)
              const Text('No errors reported')
            else
              ..._errors.take(3).map((error) => Text('• $error')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      errorHandler.clearErrors();
                      _loadData();
                    },
                    child: const Text('Clear Errors'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      appPerformance.clearStats();
                      _loadData();
                    },
                    child: const Text('Reset Stats'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
