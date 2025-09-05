import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance metrics
  final Map<String, List<Duration>> _operationTimings = {};
  final Map<String, int> _operationCounts = {};
  final Map<String, List<String>> _errors = {};

  // Memory usage tracking
  int _peakMemoryUsage = 0;
  final List<int> _memorySnapshots = [];

  // Network performance
  final Map<String, List<Duration>> _apiResponseTimes = {};
  final Map<String, int> _apiCallCounts = {};

  // UI performance
  final List<Duration> _frameRenderTimes = [];
  int _frameCount = 0;

  // Start time for overall app performance
  final DateTime _appStartTime = DateTime.now();

  // Start monitoring an operation
  void startOperation(String operationName) {
    if (!_operationTimings.containsKey(operationName)) {
      _operationTimings[operationName] = [];
      _operationCounts[operationName] = 0;
    }

    _operationTimings[operationName]!.add(Duration.zero);
    _operationCounts[operationName] =
        (_operationCounts[operationName] ?? 0) + 1;
  }

  // End monitoring an operation
  void endOperation(String operationName, Duration duration) {
    if (_operationTimings.containsKey(operationName)) {
      final index = _operationTimings[operationName]!.length - 1;
      if (index >= 0) {
        _operationTimings[operationName]![index] = duration;
      }
    }
  }

  // Record an error
  void recordError(String operationName, String error) {
    if (!_errors.containsKey(operationName)) {
      _errors[operationName] = [];
    }
    _errors[operationName]!.add(error);

    if (kDebugMode) {
      print('Performance Error in $operationName: $error');
    }
  }

  // Record API response time
  void recordApiResponseTime(String endpoint, Duration responseTime) {
    if (!_apiResponseTimes.containsKey(endpoint)) {
      _apiResponseTimes[endpoint] = [];
      _apiCallCounts[endpoint] = 0;
    }

    _apiResponseTimes[endpoint]!.add(responseTime);
    _apiCallCounts[endpoint] = (_apiCallCounts[endpoint] ?? 0) + 1;
  }

  // Record frame render time
  void recordFrameRenderTime(Duration renderTime) {
    _frameRenderTimes.add(renderTime);
    _frameCount++;

    // Keep only last 1000 frames to prevent memory issues
    if (_frameRenderTimes.length > 1000) {
      _frameRenderTimes.removeAt(0);
    }
  }

  // Record memory usage snapshot
  void recordMemorySnapshot(int memoryUsage) {
    _memorySnapshots.add(memoryUsage);
    if (memoryUsage > _peakMemoryUsage) {
      _peakMemoryUsage = memoryUsage;
    }

    // Keep only last 100 snapshots
    if (_memorySnapshots.length > 100) {
      _memorySnapshots.removeAt(0);
    }
  }

  // Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final now = DateTime.now();
    final uptime = now.difference(_appStartTime);

    return {
      'app_uptime': uptime.inSeconds,
      'operations': _getOperationSummary(),
      'api_performance': _getApiPerformanceSummary(),
      'ui_performance': _getUIPerformanceSummary(),
      'memory_usage': _getMemoryUsageSummary(),
      'errors': _getErrorSummary(),
      'timestamp': now.toIso8601String(),
    };
  }

  Map<String, dynamic> _getOperationSummary() {
    final summary = <String, dynamic>{};

    for (final entry in _operationTimings.entries) {
      final operationName = entry.key;
      final timings = entry.value;
      final count = _operationCounts[operationName] ?? 0;

      if (timings.isNotEmpty) {
        final avgDuration =
            timings.fold(Duration.zero, (sum, duration) => sum + duration) ~/
                timings.length;
        final maxDuration = timings.reduce((a, b) => a > b ? a : b);
        final minDuration = timings.reduce((a, b) => a < b ? a : b);

        summary[operationName] = {
          'count': count,
          'average_duration_ms': avgDuration.inMilliseconds,
          'max_duration_ms': maxDuration.inMilliseconds,
          'min_duration_ms': minDuration.inMilliseconds,
          'total_duration_ms':
              timings.fold(0, (sum, duration) => sum + duration.inMilliseconds),
        };
      }
    }

    return summary;
  }

  Map<String, dynamic> _getApiPerformanceSummary() {
    final summary = <String, dynamic>{};

    for (final entry in _apiResponseTimes.entries) {
      final endpoint = entry.key;
      final responseTimes = entry.value;
      final count = _apiCallCounts[endpoint] ?? 0;

      if (responseTimes.isNotEmpty) {
        final avgResponseTime = responseTimes.fold(
                Duration.zero, (sum, duration) => sum + duration) ~/
            responseTimes.length;
        final maxResponseTime = responseTimes.reduce((a, b) => a > b ? a : b);
        final minResponseTime = responseTimes.reduce((a, b) => a < b ? a : b);

        summary[endpoint] = {
          'call_count': count,
          'average_response_time_ms': avgResponseTime.inMilliseconds,
          'max_response_time_ms': maxResponseTime.inMilliseconds,
          'min_response_time_ms': minResponseTime.inMilliseconds,
          'success_rate': _calculateSuccessRate(endpoint),
        };
      }
    }

    return summary;
  }

  Map<String, dynamic> _getUIPerformanceSummary() {
    if (_frameRenderTimes.isEmpty) {
      return {'frame_count': 0, 'average_render_time_ms': 0};
    }

    final avgRenderTime = _frameRenderTimes.fold(
            Duration.zero, (sum, duration) => sum + duration) ~/
        _frameRenderTimes.length;
    final maxRenderTime = _frameRenderTimes.reduce((a, b) => a > b ? a : b);
    final minRenderTime = _frameRenderTimes.reduce((a, b) => a < b ? a : b);

    return {
      'frame_count': _frameCount,
      'average_render_time_ms': avgRenderTime.inMilliseconds,
      'max_render_time_ms': maxRenderTime.inMilliseconds,
      'min_render_time_ms': minRenderTime.inMilliseconds,
      'frames_per_second': _calculateFPS(),
    };
  }

  Map<String, dynamic> _getMemoryUsageSummary() {
    if (_memorySnapshots.isEmpty) {
      return {'current_usage': 0, 'peak_usage': 0, 'average_usage': 0};
    }

    final currentUsage = _memorySnapshots.last;
    final averageUsage =
        _memorySnapshots.fold(0, (sum, usage) => sum + usage) ~/
            _memorySnapshots.length;

    return {
      'current_usage_kb': currentUsage,
      'peak_usage_kb': _peakMemoryUsage,
      'average_usage_kb': averageUsage,
      'snapshot_count': _memorySnapshots.length,
    };
  }

  Map<String, dynamic> _getErrorSummary() {
    final summary = <String, dynamic>{};

    for (final entry in _errors.entries) {
      final operationName = entry.key;
      final errorList = entry.value;

      summary[operationName] = {
        'error_count': errorList.length,
        'recent_errors': errorList.take(5).toList(), // Last 5 errors
      };
    }

    return summary;
  }

  double _calculateSuccessRate(String endpoint) {
    final totalCalls = _apiCallCounts[endpoint] ?? 0;
    final errorCount = _errors[endpoint]?.length ?? 0;

    if (totalCalls == 0) return 0.0;
    return ((totalCalls - errorCount) / totalCalls) * 100;
  }

  double _calculateFPS() {
    if (_frameCount < 2) return 0.0;

    final totalTime = _frameRenderTimes.fold(
        Duration.zero, (sum, duration) => sum + duration);
    final avgFrameTime = totalTime.inMicroseconds / _frameCount;

    return 1000000 / avgFrameTime; // Convert to FPS
  }

  // Clear all performance data
  void clearPerformanceData() {
    _operationTimings.clear();
    _operationCounts.clear();
    _errors.clear();
    _apiResponseTimes.clear();
    _apiCallCounts.clear();
    _frameRenderTimes.clear();
    _memorySnapshots.clear();
    _frameCount = 0;
    _peakMemoryUsage = 0;
  }

  // Get specific operation performance
  Map<String, dynamic>? getOperationPerformance(String operationName) {
    if (!_operationTimings.containsKey(operationName)) return null;

    final timings = _operationTimings[operationName]!;
    final count = _operationCounts[operationName] ?? 0;

    if (timings.isEmpty) return null;

    final avgDuration =
        timings.fold(Duration.zero, (sum, duration) => sum + duration) ~/
            timings.length;
    final maxDuration = timings.reduce((a, b) => a > b ? a : b);
    final minDuration = timings.reduce((a, b) => a < b ? a : b);

    return {
      'operation_name': operationName,
      'total_calls': count,
      'average_duration_ms': avgDuration.inMilliseconds,
      'max_duration_ms': maxDuration.inMilliseconds,
      'min_duration_ms': minDuration.inMilliseconds,
      'recent_timings': timings.take(10).map((d) => d.inMilliseconds).toList(),
    };
  }

  // Check if performance is within acceptable limits
  bool isPerformanceAcceptable() {
    // Check frame render times (should be < 16ms for 60fps)
    if (_frameRenderTimes.isNotEmpty) {
      final recentFrames = _frameRenderTimes.take(10);
      final slowFrames =
          recentFrames.where((time) => time.inMilliseconds > 16).length;
      if (slowFrames > 2) return false; // More than 2 slow frames in last 10
    }

    // Check API response times (should be < 1000ms)
    for (final responseTimes in _apiResponseTimes.values) {
      if (responseTimes.isNotEmpty) {
        final recentResponses = responseTimes.take(5);
        final slowResponses =
            recentResponses.where((time) => time.inMilliseconds > 1000).length;
        if (slowResponses > 1)
          return false; // More than 1 slow response in last 5
      }
    }

    // Check error rate (should be < 10%)
    final totalOperations =
        _operationCounts.values.fold(0, (sum, count) => sum + count);
    final totalErrors =
        _errors.values.fold(0, (sum, errors) => sum + errors.length);

    if (totalOperations > 0) {
      final errorRate = (totalErrors / totalOperations) * 100;
      if (errorRate > 10) return false;
    }

    return true;
  }
}

// Global instance
final performanceMonitor = PerformanceMonitor();
