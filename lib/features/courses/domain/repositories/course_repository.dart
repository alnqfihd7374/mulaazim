import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/course.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<Course>>> getCourses();
  Future<Either<Failure, void>> addCourse(Course course);
  Future<Either<Failure, void>> updateCourse(Course course);
  Future<Either<Failure, void>> deleteCourse(String courseId);
  Future<Either<Failure, void>> clearCourses();
}
