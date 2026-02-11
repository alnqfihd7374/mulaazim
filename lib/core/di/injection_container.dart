import 'package:get_it/get_it.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../../features/onboarding/data/repositories/user_repository_impl.dart';
import '../../features/onboarding/domain/repositories/user_repository.dart';
import '../../features/courses/data/repositories/course_repository_impl.dart';
import '../../features/courses/domain/repositories/course_repository.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/courses/presentation/bloc/course_bloc.dart';
import '../theme/theme_cubit.dart';


final sl = GetIt.instance;




Future<void> init() async {
  // Services
  sl.registerLazySingleton<StorageService>(() => StorageService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());

  // Repositories
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<CourseRepository>(() => CourseRepositoryImpl(sl()));


  // BLoCs
  sl.registerFactory(() => OnboardingBloc(userRepository: sl()));
  sl.registerFactory(() => DashboardBloc(userRepository: sl()));
  sl.registerFactory(() => CourseBloc(
    courseRepository: sl(),
    notificationService: sl(),
  ));
  sl.registerFactory(() => ThemeCubit(userRepository: sl()));

}
