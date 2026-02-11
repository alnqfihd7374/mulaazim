import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';


class UserRepositoryImpl implements UserRepository {
  final StorageService storageService;

  UserRepositoryImpl(this.storageService);

  @override
  Future<Either<Failure, void>> saveUser(UserModel user) async {
    try {
      await storageService.userBox.put('currentUser', user);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getUser() async {
    try {
      final user = storageService.userBox.get('currentUser');
      return Right(user);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearUser() async {
    try {
      await storageService.userBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}

