import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../onboarding/domain/repositories/user_repository.dart';
import '../../../onboarding/data/models/user_model.dart';

// Events
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class UpdateUserProfile extends DashboardEvent {
  final UserModel user;
  UpdateUserProfile(this.user);
  @override
  List<Object?> get props => [user];
}

// States
abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final UserModel user;

  DashboardLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class DashboardFailure extends DashboardState {
  final String message;

  DashboardFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final UserRepository userRepository;

  DashboardBloc({required this.userRepository}) : super(DashboardInitial()) {
    on<LoadDashboardData>((event, emit) async {
      emit(DashboardLoading());

      final result = await userRepository.getUser();

      result.fold(
        (failure) => emit(DashboardFailure(_mapFailureToMessage(failure))),
        (user) {
          if (user != null) {
            emit(DashboardLoaded(user: user));
          } else {
             emit(DashboardFailure('User not found'));
          }
        },
      );
    });

    on<UpdateUserProfile>((event, emit) async {
      emit(DashboardLoading());
      final result = await userRepository.saveUser(event.user);
      result.fold(
        (failure) => emit(DashboardFailure(_mapFailureToMessage(failure))),
        (_) => add(LoadDashboardData()),
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
