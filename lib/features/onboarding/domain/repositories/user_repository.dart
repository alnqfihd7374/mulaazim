import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, void>> saveUser(UserModel user);
  Future<Either<Failure, UserModel?>> getUser();
  Future<Either<Failure, void>> clearUser();
}

