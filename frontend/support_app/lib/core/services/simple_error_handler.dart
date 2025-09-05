import 'package:flutter/foundation.dart';

class SimpleErrorHandler {
  static final SimpleErrorHandler _instance = SimpleErrorHandler._internal();
  factory SimpleErrorHandler() => _instance;
  SimpleErrorHandler._internal();

  final List<String> _errors = [];
  final int _maxErrors = 50;

  void handleError(String operation, dynamic error) {
    final errorMessage = '[$operation] $error';
    _errors.add(errorMessage);

    if (_errors.length > _maxErrors) {
      _errors.removeAt(0);
    }

    if (kDebugMode) {
      print('Error: $errorMessage');
    }
  }

  List<String> getErrors() => List.from(_errors);

  void clearErrors() => _errors.clear();

  int getErrorCount() => _errors.length;
}

final errorHandler = SimpleErrorHandler();
