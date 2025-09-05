import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:support_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:support_app/features/machines/presentation/bloc/machine_bloc.dart';
import 'package:support_app/injection_container.dart' as di;
import 'package:support_app/router.dart';
import 'package:support_app/core/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme service
  final themeService = ThemeService();
  await themeService.initialize();

  // Initialize dependency injection
  await di.init();

  // Validate token on app start
  final sharedPreferences = await SharedPreferences.getInstance();
  final token = sharedPreferences.getString('token');
  if (token == 'dummy_token') {
    // Clear invalid token
    await sharedPreferences.remove('token');
    print('⚠️ Cleared invalid dummy token on app start');
  }

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;

  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (context) =>
                    di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
              ),
              BlocProvider<ChatBloc>(
                create: (context) => di.sl<ChatBloc>(),
              ),
              BlocProvider<MachineBloc>(
                create: (context) => di.sl<MachineBloc>(),
              ),
            ],
            child: MaterialApp.router(
              routerConfig: appRouter,
              title: 'Stealth Machine Tools',
              theme: themeService.currentTheme,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
