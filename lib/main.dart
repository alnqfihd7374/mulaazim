import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/onboarding/domain/repositories/user_repository.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI and Storage
  await di.init();

  final storageService = di.sl<StorageService>();
  await storageService.init();

  final notificationService = di.sl<NotificationService>();
  await notificationService.init();

  runApp(
    BlocProvider(
      create: (context) => di.sl<ThemeCubit>(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return FutureBuilder<bool>(
          future: _isUserLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
            }
            
            final bool isLoggedIn = snapshot.data ?? false;
            
            return MaterialApp(
              title: 'Mulaazim',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: isLoggedIn 
                  ? const DashboardPage() 
                  : BlocProvider(
                      create: (context) => di.sl<OnboardingBloc>(),
                      child: const OnboardingPage(),
                    ),
            );
          },
        );
      },
    );
  }

  Future<bool> _isUserLoggedIn() async {
    final result = await di.sl<UserRepository>().getUser();
    return result.fold((_) => false, (user) => user != null);
  }
}
