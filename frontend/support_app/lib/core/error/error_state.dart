part of 'error_bloc.dart';

abstract class ErrorState extends Equatable {
  const ErrorState();

  @override
  List<Object?> get props => [];
}

class ErrorInitial extends ErrorState {}

class ErrorOccurred extends ErrorState {
  final String message;
  final ErrorType type;

  const ErrorOccurred({
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [message, type];
}

enum ErrorType {
  authentication,
  network,
  server,
  client,
  unknown,
}
