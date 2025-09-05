// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:support_app/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i551;
import 'package:support_app/features/auth/data/repositories/auth_repository_impl.dart'
    as _i792;
import 'package:support_app/features/auth/domain/repositories/auth_repository.dart'
    as _i17;
import 'package:support_app/features/auth/domain/usecases/change_password.dart'
    as _i182;
import 'package:support_app/features/auth/domain/usecases/login.dart' as _i706;
import 'package:support_app/features/auth/domain/usecases/register.dart'
    as _i653;
import 'package:support_app/features/auth/domain/usecases/request_otp.dart'
    as _i564;
import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart'
    as _i1024;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i551.AuthRemoteDataSource>(
        () => _i551.AuthRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i17.AuthRepository>(() => _i792.AuthRepositoryImpl(
          gh<_i551.AuthRemoteDataSource>(),
          gh<_i460.SharedPreferences>(),
        ));
    gh.lazySingleton<_i706.Login>(() => _i706.Login(gh<_i17.AuthRepository>()));
    gh.lazySingleton<_i653.Register>(
        () => _i653.Register(gh<_i17.AuthRepository>()));
    gh.lazySingleton<_i564.RequestOtp>(
        () => _i564.RequestOtp(gh<_i17.AuthRepository>()));
    gh.lazySingleton<_i182.ChangePassword>(
        () => _i182.ChangePassword(gh<_i17.AuthRepository>()));
    gh.factory<_i1024.AuthBloc>(() => _i1024.AuthBloc(
          gh<_i706.Login>(),
          gh<_i653.Register>(),
          gh<_i564.RequestOtp>(),
          gh<_i182.ChangePassword>(),
        ));
    return this;
  }
}
