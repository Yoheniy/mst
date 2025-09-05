part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String fullName;
  final String password;
  final String serialNumber;

  const RegisterEvent(
      this.email, this.fullName, this.password, this.serialNumber);

  @override
  List<Object> get props => [email, fullName, password, serialNumber];
}

// ... existing ...

class RequestOtpEvent extends AuthEvent {
  // NEW
  final String email;

  const RequestOtpEvent(this.email);

  @override
  List<Object> get props => [email];
}

class ChangePasswordEvent extends AuthEvent {
  // NEW
  final String email;
  final String otp;
  final String newPassword;

  const ChangePasswordEvent(this.email, this.otp, this.newPassword);

  @override
  List<Object> get props => [email, otp, newPassword];
}

class LogoutEvent extends AuthEvent {} // NEW
