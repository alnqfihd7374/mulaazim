import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/onboarding/domain/repositories/user_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final UserRepository userRepository;

  ThemeCubit({required this.userRepository}) : super(ThemeMode.light) {
    loadTheme();
  }

  void loadTheme() async {
    final result = await userRepository.getUser();
    result.fold(
      (_) => emit(ThemeMode.light),
      (user) {
        if (user != null) {
          emit(user.isDarkMode ? ThemeMode.dark : ThemeMode.light);
        }
      },
    );
  }

  void toggleTheme(bool isDarkMode) async {
    emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    
    final result = await userRepository.getUser();
    result.fold(
      (_) => null,
      (user) async {
        if (user != null) {
          final updatedUser = user.copyWith(isDarkMode: isDarkMode);
          await userRepository.saveUser(updatedUser);
        }
      },
    );
  }
}
