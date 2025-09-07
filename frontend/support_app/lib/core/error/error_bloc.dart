import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

part 'error_event.dart';
part 'error_state.dart';

@LazySingleton()
class ErrorBloc extends Bloc<ErrorEvent, ErrorState> {
  ErrorBloc() : super(ErrorInitial()) {
    on<HandleError>(_onHandleError);
    on<ClearError>(_onClearError);
  }

  void _onHandleError(HandleError event, Emitter<ErrorState> emit) {
    final error = event.error;
    String message;
    ErrorType type;

    if (error is DioException) {
      message = _getDioErrorMessage(error);
      type = _getDioErrorType(error);
    } else {
      message = error.toString();
      type = ErrorType.unknown;
    }

    emit(ErrorOccurred(message: message, type: type));
  }

  void _onClearError(ClearError event, Emitter<ErrorState> emit) {
    emit(ErrorInitial());
  }

  String _getDioErrorMessage(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode!;

      switch (statusCode) {
        case 401:
          return 'Session expired. Please login again.';
        case 403:
          return 'Access denied. You don\'t have permission.';
        case 404:
          return 'Resource not found.';
        case 422:
          return 'Validation error. Please check your data.';
        case 429:
          return 'Too many requests. Please try again later.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return 'An error occurred. Please try again.';
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      default:
        return 'Network error. Please check your connection.';
    }
  }

  ErrorType _getDioErrorType(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode!;

      if (statusCode == 401) return ErrorType.authentication;
      if (statusCode >= 500) return ErrorType.server;
      if (statusCode >= 400) return ErrorType.client;
    }

    return ErrorType.network;
  }
}
