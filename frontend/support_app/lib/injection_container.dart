import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_app/core/services/basic_network_service.dart';
import 'injection_container.config.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/machines/domain/repositories/machine_repository.dart';
import 'features/machines/data/repositories/machine_repository_impl.dart';
import 'features/machines/domain/usecases/get_machines.dart';
import 'features/machines/domain/usecases/create_machine.dart';
import 'features/machines/presentation/bloc/machine_bloc.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> init() async {
  sl.init();

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Initialize network service and get its Dio instance
  final networkService = BasicNetworkService();
  networkService.initialize();
  final dio = networkService.dio;

  // Update base URL for local development
  dio.options.baseUrl = 'http://0.0.0.0:8000';

  // Add auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = sl<SharedPreferences>().getString('token');
      if (token != null && token != 'dummy_token') {
        options.headers['Authorization'] = 'Bearer $token';
      }

      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';

      print(
          '🌐 API Request: ${options.method} ${options.baseUrl}${options.path}');
      handler.next(options);
    },
  ));

  // Register the Dio instance from BasicNetworkService
  sl.registerSingleton<Dio>(dio);

  // Chat dependencies (needed by LogoutService)
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(dio, sl<SharedPreferences>()),
  );

  // Core services are registered by injectable generator

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(sl<ChatRepository>()),
  );

  // Machine dependencies
  sl.registerLazySingleton<MachineRepository>(
    () => MachineRepositoryImpl(),
  );

  sl.registerLazySingleton<GetMachines>(
    () => GetMachines(sl<MachineRepository>()),
  );

  sl.registerLazySingleton<CreateMachine>(
    () => CreateMachine(sl<MachineRepository>()),
  );

  sl.registerFactory<MachineBloc>(
    () => MachineBloc(
      getMachines: sl<GetMachines>(),
      createMachine: sl<CreateMachine>(),
    ),
  );
}
