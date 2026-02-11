import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import '../../../../core/error/failures.dart';

// Events
abstract class OnboardingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitUserInfo extends OnboardingEvent {
  final String firstName;
  final String secondName;
  final String? surName;
  final String? nickname;
  final bool isDarkMode;

  SubmitUserInfo({
    required this.firstName,
    required this.secondName,
    this.surName,
    this.nickname,
    required this.isDarkMode,
  });

  @override
  List<Object?> get props => [firstName, secondName, surName, nickname, isDarkMode];
}

// States
abstract class OnboardingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingSuccess extends OnboardingState {}

class OnboardingFailure extends OnboardingState {
  final String message;

  OnboardingFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserRepository userRepository;

  OnboardingBloc({required this.userRepository}) : super(OnboardingInitial()) {
    on<SubmitUserInfo>((event, emit) async {
      emit(OnboardingLoading());

      final user = UserModel(
        firstName: event.firstName,
        secondName: event.secondName,
        surName: event.surName,
        nickname: event.nickname,
        isDarkMode: event.isDarkMode,
      );

      final result = await userRepository.saveUser(user);

      result.fold(
        (failure) => emit(OnboardingFailure(_mapFailureToMessage(failure))),
        (_) => emit(OnboardingSuccess()),
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is CacheFailure) {
      return 'Cache Failure';
    } else {
      return 'Unexpected Error';
    }
  }
}
