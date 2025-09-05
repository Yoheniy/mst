import 'package:flutter/foundation.dart';

class AppPerformance {
  static final AppPerformance _instance = AppPerformance._internal();
  factory AppPerformance() => _instance;
  AppPerformance._internal();

  final Map<String, int> _operationCounts = {};
  final Map<String, List<String>> _errors = {};
  final DateTime _startTime = DateTime.now();

  void recordOperation(String operationName) {
    _operationCounts[operationName] =
        (_operationCounts[operationName] ?? 0) + 1;
  }

  void recordError(String operationName, String error) {
    if (!_errors.containsKey(operationName)) {
      _errors[operationName] = [];
    }
    _errors[operationName]!.add(error);

    if (kDebugMode) {
      print('Error in $operationName: $error');
    }
  }

  Map<String, dynamic> getStats() {
    final uptime = DateTime.now().difference(_startTime);

    return {
      'uptime_seconds': uptime.inSeconds,
      'operations': _operationCounts,
      'error_count':
          _errors.values.fold(0, (sum, errors) => sum + errors.length),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void clearStats() {
    _operationCounts.clear();
    _errors.clear();
  }
}

final appPerformance = AppPerformance();
