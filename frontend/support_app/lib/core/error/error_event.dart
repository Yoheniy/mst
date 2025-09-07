part of 'error_bloc.dart';

abstract class ErrorEvent extends Equatable {
  const ErrorEvent();

  @override
  List<Object?> get props => [];
}

class HandleError extends ErrorEvent {
  final dynamic error;

  const HandleError(this.error);

  @override
  List<Object?> get props => [error];
}

class ClearError extends ErrorEvent {
  const ClearError();
}
