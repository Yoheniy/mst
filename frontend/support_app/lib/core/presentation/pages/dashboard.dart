import 'package:flutter/material.dart';
import '../../config/production_config.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Environment: ${productionConfig.apiUrl}'),
            Text('Advanced RAG: ${productionConfig.enableAdvancedRAG}'),
            Text(
                'Performance Monitoring: ${productionConfig.enablePerformanceMonitoring}'),
            Text('Error Reporting: ${productionConfig.enableErrorReporting}'),
          ],
        ),
      ),
    );
  }
}
