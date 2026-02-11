import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../courses/presentation/bloc/course_bloc.dart';
import '../../../courses/data/models/course.dart';
import '../../../courses/data/models/pending_lesson.dart';


class PendingLessonsPage extends StatelessWidget {
  const PendingLessonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CourseBloc>()..add(LoadCourses()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'قائمة الاستدراك',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
           backgroundColor: Colors.transparent,
           elevation: 0,
           foregroundColor: AppColors.primary,
        ),
        body: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CourseLoaded) {
              final pendingItems = _getAllPendingLessons(state.courses);
              
              if (pendingItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'لا يوجد دروس متأخرة',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingItems.length,
                itemBuilder: (context, index) {
                  final item = pendingItems[index];
                  final course = item['course'] as Course;
                  final pending = item['pending'] as PendingLesson;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 course.bookName,
                                 style: GoogleFonts.tajawal(
                                   fontSize: 16,
                                   fontWeight: FontWeight.bold,
                                   color: AppColors.primary,
                                 ),
                               ),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: Colors.red.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: Text(
                                   'درس ${pending.lessonNumber}',
                                   style: GoogleFonts.tajawal(
                                     color: Colors.red,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 8),
                           Row(
                             children: [
                               const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                               const SizedBox(width: 4),
                               Text(
                                 '${pending.missedDate.day}/${pending.missedDate.month}/${pending.missedDate.year}',
                                 style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey),
                               ),
                               const SizedBox(width: 16),
                               const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                               const SizedBox(width: 4),
                               Text(
                                 pending.reason ?? 'بدون سبب',
                                 style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey),
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           SizedBox(
                             width: double.infinity,
                             child: ElevatedButton.icon(
                               onPressed: () {
                                 context.read<CourseBloc>().add(MarkLessonAsDone(
                                   course: course,
                                   lesson: pending,
                                 ));
                               },
                               icon: const Icon(Icons.check),
                               label: const Text('تم السماع'),

                               style: ElevatedButton.styleFrom(
                                 backgroundColor: AppColors.primary,
                                 foregroundColor: Colors.white,
                               ),
                             ),
                           ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Error loading data'));
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAllPendingLessons(List<Course> courses) {
    List<Map<String, dynamic>> items = [];
    for (var c in courses) {
      for (var p in c.pendingLessons) {
        if (!p.isHeard) {

          items.add({
            'course': c,
            'pending': p,
          });
        }
      }
    }
    // Sort logic here if needed
    return items;
  }
}
