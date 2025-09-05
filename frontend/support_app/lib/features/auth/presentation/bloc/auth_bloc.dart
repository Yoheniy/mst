import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_app/features/auth/domain/entities/user.dart';
import 'package:support_app/features/auth/domain/usecases/change_password.dart';
import 'package:support_app/features/auth/domain/usecases/login.dart';
import 'package:support_app/features/auth/domain/usecases/register.dart';
import 'package:support_app/features/auth/domain/usecases/request_otp.dart';
import 'package:support_app/injection_container.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login loginUseCase;
  final Register registerUseCase;
  final RequestOtp requestOtpUseCase;
  final ChangePassword changePasswordUseCase;

  AuthBloc(this.loginUseCase, this.registerUseCase, this.requestOtpUseCase,
      this.changePasswordUseCase)
      : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<RequestOtpEvent>(_onRequestOtp);
    on<ChangePasswordEvent>(_onChangePassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Check if user is already authenticated from stored data
      final sharedPrefs = sl<SharedPreferences>();
      final token = sharedPrefs.getString('token');
      final userEmail = sharedPrefs.getString('user_email');
      final userName = sharedPrefs.getString('user_name');

      if (token != null && userEmail != null && userName != null) {
        // User is already authenticated
        final user = User(
          id: 0, // We don't store the full user object, so use a placeholder
          email: userEmail,
          fullName: userName,
          role: 'customer', // Default role
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(event.email, event.password));

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        // Store user data locally (token is handled by repository)
        final sharedPrefs = sl<SharedPreferences>();
        await sharedPrefs.setString('user_email', user.email);
        await sharedPrefs.setString('user_name', user.fullName);

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(RegisterParams(
        event.email, event.fullName, event.password, event.serialNumber));

    await result.fold(
      (failure) async {
        emit(AuthError(failure.message));
      },
      (user) async {
        // Store user data locally (token is handled by repository)
        final sharedPrefs = sl<SharedPreferences>();
        await sharedPrefs.setString('user_email', user.email);
        await sharedPrefs.setString('user_name', user.fullName);

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRequestOtp(
      RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await requestOtpUseCase(RequestOtpParams(event.email));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpSent()),
    );
  }

  Future<void> _onChangePassword(
      ChangePasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await changePasswordUseCase(
        ChangePasswordParams(event.email, event.otp, event.newPassword));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    final sharedPrefs = sl<SharedPreferences>();
    await sharedPrefs.remove('token');
    await sharedPrefs.remove('user_email');
    await sharedPrefs.remove('user_name');
    emit(AuthUnauthenticated());
  }
}
