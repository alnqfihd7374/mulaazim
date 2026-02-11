import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/course.dart';
import '../../domain/repositories/course_repository.dart';


class CourseRepositoryImpl implements CourseRepository {
  final StorageService storageService;

  CourseRepositoryImpl(this.storageService);

  @override
  Future<Either<Failure, List<Course>>> getCourses() async {
    try {
      final courses = storageService.coursesBox.values.toList();
      return Right(courses);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addCourse(Course course) async {
    try {
      await storageService.coursesBox.put(course.id, course);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateCourse(Course course) async {
    try {
      await storageService.coursesBox.put(course.id, course);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }


  @override
  Future<Either<Failure, void>> deleteCourse(String courseId) async {
    try {
      await storageService.coursesBox.delete(courseId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearCourses() async {
    try {
      await storageService.coursesBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
