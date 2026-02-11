import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../courses/data/models/course.dart';


class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress (Mock logic for now, real logic will depend on total lessons if known, or just attendance rate)
    // For now, let's just show a visual indicator of consistency or something generic.
    // Or maybe we don't show a progress bar yet if we don't have total lessons.
    // The prompt says: "Progress Bar: Green for attendance, Red for absence".
    // Since we don't have history fully visualized here yet, let's make a simple bar based on attendance rate if available, or just a placeholder style.
    
    // Let's assume we show the last 5 lessons status as small dots instead of a long bar for the summary card.
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.bookName,
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                       Text(
                        '${course.teacherTitle} ${course.teacherName}',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFBDBDBD) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                   ),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(
                       color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : AppColors.primary.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Text(
                       'الدرس ${course.currentLessonNumber}',
                       style: GoogleFonts.tajawal(
                         color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.primary,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 16),
              // Next Lesson Info (Derived)
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _getNextLessonDay(course.scheduleDays),
                    style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextLessonDay(List<int> days) {
    if (days.isEmpty) return 'غير محدد';
    // Simple logic to find next day
    final now = DateTime.now().weekday;
    // Sort days
    days.sort();
    
    for (var day in days) {
      if (day >= now) {
         return _dayToString(day);
      }
    }
    // If wrapping around
    return _dayToString(days.first);
  }

  String _dayToString(int day) {
     switch(day) {
       case 1: return 'الإثنين';
       case 2: return 'الثلاثاء';
       case 3: return 'الأربعاء';
       case 4: return 'الخميس';
       case 5: return 'الجمعة';
       case 6: return 'السبت';
       case 7: return 'الأحد';
       default: return '';
     }
  }
}
