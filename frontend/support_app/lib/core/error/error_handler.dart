import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class ErrorHandler {
  static const Map<int, String> _errorMessages = {
    400: 'Bad Request - Please check your input',
    401: 'Session expired - Please login again',
    403: 'Access denied - You don\'t have permission',
    404: 'Resource not found',
    409: 'Conflict - Resource already exists',
    422: 'Validation error - Please check your data',
    429: 'Too many requests - Please try again later',
    500: 'Server error - Please try again later',
    502: 'Bad Gateway - Service temporarily unavailable',
    503: 'Service unavailable - Please try again later',
  };

  static String getErrorMessage(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode!;
      final message = _errorMessages[statusCode];

      if (message != null) {
        return message;
      }

      // Try to get error message from response
      final responseData = error.response!.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['detail'] ??
            responseData['message'] ??
            'Unknown error';
      }
    }

    // Network errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout - Please check your internet';
      case DioExceptionType.sendTimeout:
        return 'Request timeout - Please try again';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout - Please try again';
      case DioExceptionType.connectionError:
        return 'Connection error - Please check your internet';
      case DioExceptionType.badResponse:
        return 'Server error - Please try again later';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return 'Unknown error - Please try again';
      default:
        return 'Network error - Please check your connection';
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showErrorDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static bool isAuthenticationError(DioException error) {
    return error.response?.statusCode == 401;
  }

  static bool isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  static bool isServerError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }
}
