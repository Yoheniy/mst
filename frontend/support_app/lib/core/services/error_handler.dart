import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/app_performance.dart';

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

class ErrorInfo {
  final String message;
  final String? stackTrace;
  final ErrorSeverity severity;
  final String operation;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  ErrorInfo({
    required this.message,
    this.stackTrace,
    required this.severity,
    required this.operation,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'stackTrace': stackTrace,
      'severity': severity.name,
      'operation': operation,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
}

class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final List<ErrorInfo> _errors = [];
  final int _maxErrors = 100; // Keep only last 100 errors

  // Error reporting callbacks
  Function(ErrorInfo)? _onErrorReported;
  Function(List<ErrorInfo>)? _onErrorsCleared;

  void setErrorCallback(Function(ErrorInfo) callback) {
    _onErrorReported = callback;
  }

  void setClearCallback(Function(List<ErrorInfo>) callback) {
    _onErrorsCleared = callback;
  }

  // Handle and log errors
  void handleError(
    dynamic error,
    String operation, {
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    final errorInfo = ErrorInfo(
      message: error.toString(),
      stackTrace: stackTrace?.toString(),
      severity: severity,
      operation: operation,
      timestamp: DateTime.now(),
      context: context,
    );

    _addError(errorInfo);
    _logError(errorInfo);
    _reportToPerformanceMonitor(errorInfo);

    // Call error callback if set
    _onErrorReported?.call(errorInfo);
  }

  // Handle Flutter framework errors
  void handleFlutterError(FlutterErrorDetails details) {
    final errorInfo = ErrorInfo(
      message: details.exception.toString(),
      stackTrace: details.stack?.toString(),
      severity: ErrorSeverity.high,
      operation: 'flutter_framework',
      timestamp: DateTime.now(),
      context: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );

    _addError(errorInfo);
    _logError(errorInfo);
    _reportToPerformanceMonitor(errorInfo);

    _onErrorReported?.call(errorInfo);
  }

  // Handle async errors
  void handleAsyncError(dynamic error, StackTrace stackTrace) {
    final errorInfo = ErrorInfo(
      message: error.toString(),
      stackTrace: stackTrace.toString(),
      severity: ErrorSeverity.medium,
      operation: 'async_operation',
      timestamp: DateTime.now(),
    );

    _addError(errorInfo);
    _logError(errorInfo);
    _reportToPerformanceMonitor(errorInfo);

    _onErrorReported?.call(errorInfo);
  }

  // Add error to internal storage
  void _addError(ErrorInfo errorInfo) {
    _errors.add(errorInfo);

    // Keep only last N errors
    if (_errors.length > _maxErrors) {
      _errors.removeAt(0);
    }
  }

  // Log error based on severity
  void _logError(ErrorInfo errorInfo) {
    if (kDebugMode) {
      final severityColor = _getSeverityColor(errorInfo.severity);
      print(
          '$severityColor[${errorInfo.severity.name.toUpperCase()}] ${errorInfo.operation}: ${errorInfo.message}\x1B[0m');

      if (errorInfo.stackTrace != null) {
        print('Stack trace: ${errorInfo.stackTrace}');
      }

      if (errorInfo.context != null) {
        print('Context: ${errorInfo.context}');
      }
    }
  }

  // Report to performance monitor
  void _reportToPerformanceMonitor(ErrorInfo errorInfo) {
    appPerformance.recordError(errorInfo.operation, errorInfo.message);
  }

  // Get errors by severity
  List<ErrorInfo> getErrorsBySeverity(ErrorSeverity severity) {
    return _errors.where((error) => error.severity == severity).toList();
  }

  // Get errors by operation
  List<ErrorInfo> getErrorsByOperation(String operation) {
    return _errors.where((error) => error.operation == operation).toList();
  }

  // Get recent errors
  List<ErrorInfo> getRecentErrors([int count = 10]) {
    return _errors.take(count).toList();
  }

  // Get error statistics
  Map<String, dynamic> getErrorStats() {
    final severityCounts = <String, int>{};
    final operationCounts = <String, int>{};

    for (final error in _errors) {
      severityCounts[error.severity.name] =
          (severityCounts[error.severity.name] ?? 0) + 1;
      operationCounts[error.operation] =
          (operationCounts[error.operation] ?? 0) + 1;
    }

    return {
      'total_errors': _errors.length,
      'severity_distribution': severityCounts,
      'operation_distribution': operationCounts,
      'critical_errors': getErrorsBySeverity(ErrorSeverity.critical).length,
      'high_errors': getErrorsBySeverity(ErrorSeverity.high).length,
      'medium_errors': getErrorsBySeverity(ErrorSeverity.medium).length,
      'low_errors': getErrorsBySeverity(ErrorSeverity.low).length,
      'last_error_time':
          _errors.isNotEmpty ? _errors.last.timestamp.toIso8601String() : null,
    };
  }

  // Clear all errors
  void clearErrors() {
    final clearedErrors = List<ErrorInfo>.from(_errors);
    _errors.clear();
    _onErrorsCleared?.call(clearedErrors);
  }

  // Clear errors by operation
  void clearErrorsByOperation(String operation) {
    _errors.removeWhere((error) => error.operation == operation);
  }

  // Check if there are critical errors
  bool hasCriticalErrors() {
    return _errors.any((error) => error.severity == ErrorSeverity.critical);
  }

  // Get error summary for production monitoring
  Map<String, dynamic> getProductionErrorSummary() {
    final criticalErrors = getErrorsBySeverity(ErrorSeverity.critical);
    final highErrors = getErrorsBySeverity(ErrorSeverity.high);

    return {
      'critical_error_count': criticalErrors.length,
      'high_error_count': highErrors.length,
      'total_error_count': _errors.length,
      'has_critical_errors': criticalErrors.isNotEmpty,
      'last_critical_error': criticalErrors.isNotEmpty
          ? criticalErrors.last.timestamp.toIso8601String()
          : null,
      'last_high_error': highErrors.isNotEmpty
          ? highErrors.last.timestamp.toIso8601String()
          : null,
      'error_rate_per_minute': _calculateErrorRate(),
    };
  }

  // Calculate error rate per minute
  double _calculateErrorRate() {
    if (_errors.isEmpty) return 0.0;

    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    final recentErrors =
        _errors.where((error) => error.timestamp.isAfter(oneMinuteAgo)).length;
    return recentErrors.toDouble();
  }

  // Get severity color for console output
  String _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        return '\x1B[31m'; // Red
      case ErrorSeverity.high:
        return '\x1B[33m'; // Yellow
      case ErrorSeverity.medium:
        return '\x1B[36m'; // Cyan
      case ErrorSeverity.low:
        return '\x1B[32m'; // Green
    }
  }

  // Export errors for external monitoring
  Map<String, dynamic> exportErrors() {
    return {
      'errors': _errors.map((error) => error.toJson()).toList(),
      'stats': getErrorStats(),
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// Global instance
final errorHandler = ErrorHandler();

// Extension for easy error handling
extension ErrorHandlingExtension on Object {
  void handleError(
    String operation, {
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    errorHandler.handleError(
      this,
      operation,
      severity: severity,
      context: context,
      stackTrace: stackTrace,
    );
  }
}
